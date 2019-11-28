/* @pjs preload="livingphysics/data/add2.png,livingphysics/data/cancel2.png,livingphysics/data/checkbox_ticked.png,livingphysics/data/clipboard2.png,livingphysics/data/cog3.png,livingphysics/data/help.png,livingphysics/data/icon-32.png,livingphysics/data/icon-48.png,livingphysics/data/icon-72.png,livingphysics/data/icon-128.png,livingphysics/data/move_left2.png,livingphysics/data/move_right2.png,livingphysics/data/reload2.png,livingphysics/data/tick2.png,livingphysics/data/trashcan2.png"; */
// (processing.js requires this)

/*

1.5: (2019-11-28)

- ported to processing.js

1.4.3: (2011-05-31)

- updated to processing 1.5.1
- back button would quit again (broke when moved to A3D)

1.4.2: (2011-04-11)

- updated to processing 0195

1.4.1: (2011-03-??)

- changed to the A3D renderer

1.4: (2011-01-25)

- new levels in full version: "Eat"
- added comment about number of reactions required to solve each level
- restart challenge shouldn't forget scroll pos

1.3: (2011-01-11)

- new levels in demo version: "Fit", "Rainbow chains"
- new levels in full version: "Match"
- added comment about elegance in solving
- built with processing 0192 - fixes loading bugs?

1.2: (2011-01-03)

- now saves reactions from every level whether succeeded or not
- new levels in full version: roll, concertina
- new levels in demo version: extend
- text in settings mode now width-limited properly
- android back button closes dialog if one open
- only congratulates when solved all levels, not just last
- on start and success, moves to next unsolved level, if any

1.1.1: (2010-12-28)

- changed behaviour on home button and url move to cause restart consistently (processing bug workaround)

1.1: (2010-12-21)

- added help pages
- made buttons look more like buttons

1.0 (2010-12-14)


TODO:

- redraw code fixes restart bug (no need to quit on home)?
- call noLoop wherever possible (mostly for js version help scroll speed)
- new levels: build
- are reactions always being saved when leaving settings mode? (back button?)
- (add help comment about  need to restart challenges and have all reactions work?)
- change size of levels chooser to be text height dependent (max determined)
- show level difficulty rating
- randomize order of atoms and reactions when checking for matching reactions
- can slow chain reactions down somehow (Signal), while not stopping spatially-unrelated reactions? (Join)

Other ideas:

- 'back' button to undo the last reaction change and revert the atoms states back to as before? (not sure this is a good idea)
- add reaction walk-through on level 2?
- tutorial walk-through on first three levels, options to restart tutorial, etc.?
- add help system on the webpage, link-to from app


Website:
- fill living physics website: user discussion area, suggestions, bug reporting
- give user an access code when they solve all puzzles, to get credit on website?
- thank processing

Release checklist:
- search for TODO strings
- version
- strip unwanted files from folders
- change name and package id for demo version and full
- build release version of demo & full, sign, zipalign, upload
- make screenshots

*/

Atom[] atoms;
Rect atoms_area;
ArrayList reactions;
boolean isDragging;
int iAtomBeingDragged;
boolean is_settings_mode;
Challenge challenges[];
int iChallenge;
boolean succeeded,cheating_detected;
ArrayList events;
Reaction last_reaction;
int last_reaction_age;
final int MY_ALPHA = 200;

boolean showing_atoms_area_help = false;

float pix;
float R;
PImage cog_image,tick_image,add_image,
  trashcan_image,cancel_image,reload_image,icon_image,clipboard_image,
  move_left_image,move_right_image,checkbox_ticked_image,help_image;
Rect cog_rect,help_rect;
String market_url_to_full_version,website_url;

final boolean is_full_version = true;
final boolean is_js_version = true;

      /* for android A2D build only:
void keyPressed()
{
  if (key == CODED && keyCode == KeyEvent.KEYCODE_HOME)
  {
    System.exit(0); // we quit on home to avoid restart bug in Processing
  }
  else if(key==CODED && keyCode==KeyEvent.KEYCODE_BACK)
  {
    keyCode = 1; // we don't always want to exit the app (see onBackPressed)
  }
}
public void onStop()
{
  super.onStop();
  System.exit(0); // without this, jumping to a URL causes the browser/market to hang
}
         */

// for android A3D build only:
/*public String sketchRenderer() {
    return A3D;
}
void keyPressed()
{
  if(key==CODED && keyCode==KeyEvent.KEYCODE_BACK)
  {
    keyCode = 1; // we don't always want to exit the app (see onBackPressed)
  }
}*/

// a suggestion on the processing forum; doesn't seem to help
//void onResume() {
//  super.onResume();
//  redraw();
//}

void setup()
{
  // android sizes: 240x320, 240x400, 240x432, 320x480, 480x800, 480x854
  // http://developer.android.com/guide/practices/screens_support.html
  size(480,800); // remove this for Android version
  //orientation(PORTRAIT);  // need this for Android version

  PFont my_font = createFont("SansSerif",32,true);
  textFont(my_font);
  pix = width/480.0; // we started on 480x800

  if(is_js_version) // (can't use "market://" protocol in a javascript environment)
    market_url_to_full_version = new String("http://www.appbrain.com/app/living-physics-%28full-version%29/uk.org.livingphysics.app.livingphysics_full");
  else
    market_url_to_full_version = new String("market://details?id=uk.org.livingphysics.app.livingphysics_full");
  website_url = new String("http://sites.google.com/site/livingphysics/");

  // show something while we load
  smooth();
  icon_image = loadImage("livingphysics/data/icon-128.png");
  drawSplashScreen();

  R = 25*pix;
  // (all of our icons are from wikimedia commons)
  cog_image = loadImage("livingphysics/data/cog3.png");
  tick_image = loadImage("livingphysics/data/tick2.png");
  add_image = loadImage("livingphysics/data/add2.png");
  trashcan_image = loadImage("livingphysics/data/trashcan2.png");
  cancel_image = loadImage("livingphysics/data/cancel2.png");
  reload_image = loadImage("livingphysics/data/reload2.png");
  clipboard_image = loadImage("livingphysics/data/clipboard2.png");
  move_left_image = loadImage("livingphysics/data/move_left2.png");
  move_right_image = loadImage("livingphysics/data/move_right2.png");
  checkbox_ticked_image = loadImage("livingphysics/data/checkbox_ticked.png");
  help_image = loadImage("livingphysics/data/help.png");
  events = new ArrayList();
  reactions = new ArrayList();
  isDragging = false;
  is_settings_mode = false;
  succeeded = false;

  float dashboard_height = 80*pix;
  atoms_area = new Rect(0,0,width,height-dashboard_height);
  cog_rect = new Rect(width-dashboard_height,height-dashboard_height,dashboard_height,dashboard_height);
  help_rect = new Rect(0,height-dashboard_height,dashboard_height,dashboard_height);

  if(is_full_version)
    challenges = (Challenge[])concat(teaser_challenges,full_version_challenges);
  else
    challenges = teaser_challenges;

  loadStatus();
  loadChallenge();
}

void draw()
{
  if(frameCount<50) { return; } // leave splash screen for a bit

  if(is_settings_mode)
    drawSettingsMode();
  else if(succeeded)
    drawSuccess();
  else if(cheating_detected)
    drawCheatingDetected();
  else if(showing_atoms_area_help)
  {
    processEvents();
    drawAtomsMode();
    showAtomsAreaHelp();
  }
  else
  {
    updateAtoms();
    updateAtoms(); // more movement per frame redraw
    drawAtomsMode();
    processEvents();
    if(frameCount%20==0)
      challenges[iChallenge].detectCheating();
    if(!cheating_detected && events.isEmpty() && frameCount%40==0)
      challenges[iChallenge].evaluateSuccess();
  }
}

void updateAtoms()
{
  for (int i = 0; i < atoms.length; i++)
    atoms[i].sumForces();
  for (int i = 0; i < atoms.length; i++)
    atoms[i].move();
}

void drawAtomsMode()
{
  // draw background (clears the screen)
  background(0,0,0);
  fill(16,47,89);
  noStroke();
  atoms_area.drawRect();
  // draw bonds
  stroke(200,200,200);
  strokeWeight(6*pix);
  for (int i = 0; i < atoms.length; i++)
    atoms[i].drawBonds();
  // draw atoms
  for (int i = 0; i < atoms.length; i++)
    atoms[i].drawAtom();
  // draw dragging arm
  if(isDragging)
  {
    stroke(180,180,180);
    strokeWeight(pix*10);
    line(mouseX,mouseY,atoms[iAtomBeingDragged].x,atoms[iAtomBeingDragged].y);
  }
  // show the last applied reaction
  float last_reaction_display_time = 100;
  if(reactions.size()==1)
    last_reaction_display_time = 1000;
  float last_reaction_fade_time = 20;
  if(last_reaction!=null && last_reaction_age<last_reaction_display_time+last_reaction_fade_time)
  {
    last_reaction_age++;
    int MY_ALPHA = 200;
    if(last_reaction_age>last_reaction_display_time)
      MY_ALPHA *= (last_reaction_display_time+last_reaction_fade_time-last_reaction_age)/last_reaction_fade_time;
    float y = (height+atoms_area.y+atoms_area.height)/2;
    float radius = 20*pix;
    float p1 = width/2-radius*(10.5/2);
    float p2 = p1+radius*3;
    float p3 = p2+radius*4.5;
    float p4 = p3+radius*3;
    float p5 = p2+radius*1.5;
    float p6 = p3-radius*1.5;
    stroke(200,200,200,MY_ALPHA);
    strokeWeight(6*pix);
    if(last_reaction.bonded_pre) line(p1,y,p2,y);
    if(last_reaction.bonded_post) line(p3,y,p4,y);
    line(p5,y,p6,y);
    line(p6-10*pix,y-10*pix,p6,y);
    line(p6-10*pix,y+10*pix,p6,y);
    drawAnAtom(p1,y,radius,last_reaction.a_type,last_reaction.a_state_pre,MY_ALPHA);
    drawAnAtom(p2,y,radius,last_reaction.b_type,last_reaction.b_state_pre,MY_ALPHA);
    drawAnAtom(p3,y,radius,last_reaction.a_type,last_reaction.a_state_post,MY_ALPHA);
    drawAnAtom(p4,y,radius,last_reaction.b_type,last_reaction.b_state_post,MY_ALPHA);
  }
  cog_rect.drawImage(cog_image);
  help_rect.drawImage(help_image);
}

void mousePressed()
{
  if(is_settings_mode)
    mousePressedInSettingsMode();
  else if(succeeded)
    mousePressedInSucceededMode();
  else if(cheating_detected)
    mousePressedInCheatingDetectedMode();
  else if(showing_atoms_area_help)
    mousePressedInAtomsAreaHelpMode();
  else if(cog_rect.contains(mouseX,mouseY))
    is_settings_mode=true;
  else if(help_rect.contains(mouseX,mouseY))
    showing_atoms_area_help=true;
  else if(atoms_area.contains(mouseX,mouseY))
    mousePressedOnAtomsArea();
}

void mousePressedOnAtomsArea()
{
  // is there an atom at that location?
  float closest_d = 100000;
  for(int i=0;i<atoms.length;i++)
  {
    float d = mag(mouseX-atoms[i].x,mouseY-atoms[i].y);
    if(d<closest_d)
    {
      closest_d = d;
      iAtomBeingDragged = i;
    }
  }
  isDragging = true;
}

void mousePressedInSucceededMode()
{
  if(!is_full_version && iChallenge==0)
  {
    goToURL(market_url_to_full_version);
  }

  succeeded = false;
  loadChallenge();
  loop();
}

void drawSuccess()
{
  noLoop();

  int iSolvedChallenge = iChallenge;

  challenges[iSolvedChallenge].markAsSolved(true);
  saveStatus();
  events.clear();

  boolean moreChallengesRemaining = moveToNextUnsolvedChallengeIfAny();

  int left = int(40*pix);
  int top = int(100*pix);
  int right = int(width-40*pix);
  int bottom = int(height-100*pix);

  drawAtomsMode();

  stroke(230,140,100);
  strokeWeight(1);
  strokeJoin(ROUND);
  fill(30,27,34,220);
  rect(left,top,right-left,bottom-top);

  fill(200,200,200);
  setTextSize(32*pix);
  textAlign(CENTER,TOP);
  if(moreChallengesRemaining)
  {
    image(tick_image,width/2-30*pix,bottom-10-60*pix,60*pix,60*pix);
    drawText("You did it!\n\nChallenge "+str(iSolvedChallenge+1)+" completed. Click to start the next challenge.",
      left+10,top+40,right-left-20);
  }
  else
  {
    String message = new String();
    if(is_full_version)
    {
      message = "You solved all the challenges!\n\nYou are awesome.";
      iChallenge = (iSolvedChallenge+1)%challenges.length;
    }
    else
      message = "You did it!\n\nDownload the full version of Living Physics for more exciting challenges!";
    drawText(message,left+10,top+40,right-left-20);
  }
}

void mouseReleased()
{
  if(showing_atoms_area_help)
    mouseReleasedInAtomsAreaHelpMode();
  else if(is_settings_mode)
    mouseReleasedInSettingsMode();
  else
    mouseReleasedInAtomsMode();
}

void mouseReleasedInAtomsMode()
{
  isDragging = false;
}

void addEvent(int type,int x,int y)
{
  events.add(new Event(type,x,y));
}

void processEvents()
{
  int i=0;
  while(true)
  {
    if(i>=events.size()) break;
    Event e = (Event)events.get(i);
    if(e.completed)
      events.remove(i); // (don't increment i since the same i now points to the next item)
    else
    {
      e.process();
      i++;
    }
  }
}

void loadChallenge()
{
  loadReactions();
  reloadChallengeKeepingExistingReactions();
}

void reloadChallengeKeepingExistingReactions()
{
  challenges[iChallenge].init();
  last_reaction_age=1000;
}

void drawSplashScreen()
{
  background(0,0,0);
  image(icon_image,width/2-64*pix,140*pix,128*pix,128*pix);
  stroke(200,200,200);
  noFill();
  setTextSize(30*pix);
  textAlign(CENTER,TOP);
  drawText("Living Physics",50*pix,300*pix,width-100*pix);
  setTextSize(24*pix);
  if(!is_full_version)
  {
    String s = "Download the full version of Living Physics for more exciting challenges.";
    float h = textHeight(s,width-100*pix);
    drawText(s,50*pix,height-h-40*pix,width-100*pix);
  }
}

void loadStatus()
{
  if(!is_js_version) // loadStrings doesn't work on JS
  {
    String challenges_solved[] = loadStrings("challenges_solved.txt");
    if(challenges_solved==null)
    {
      // initialise our strings
      saveStatus();
    }
    else
    {
      // parse the strings
      for(int i=0;i<challenges.length;i++)
      {
        // search for this challenge in the list of strings
        for(int j=0;j<challenges_solved.length;j++)
        {
          if(match(challenges_solved[j],challenges[i].id)!=null)
          {
            String tokens[] = split(challenges_solved[j],":");
            challenges[i].markAsSolved(match(tokens[1],"yes")!=null);
            break;
          }
        }
      }
    }
  }
  // start with the first unsolved challenge
  moveToNextUnsolvedChallengeIfAny();
}

boolean moveToNextUnsolvedChallengeIfAny()
{
  int ic;
  for(int i=0;i<challenges.length;i++)
  {
    ic = (iChallenge+i)%challenges.length;
    if(!challenges[ic].isSolved())
    {
      iChallenge = ic;
      return true;
    }
  }
  iChallenge=0; // if all solved then start at the beginning by default
  return false;
}

void saveStatus()
{
  if(is_js_version) return; // saveStrings doesn't work in JS

  String challenges_solved[] = new String[challenges.length];
  for(int i=0;i<challenges.length;i++)
    challenges_solved[i] = new String(challenges[i].id + ":" + ((challenges[i].isSolved())?"yes":"no"));
  saveStrings("challenges_solved.txt",challenges_solved);
}

void drawCheatingDetected()
{
  events.clear();

  setTextSize(32*pix);
  textAlign(CENTER,TOP);
  int left = int(40*pix);
  int right = int(width-40*pix);
  float ht = 110*pix + textHeight(challenges[iChallenge].cheating_message,right-left-20*pix);
  int top = int(height/2-ht/2);
  int bottom = int(height/2+ht/2);

  drawAtomsMode();

  stroke(230,140,100);
  strokeWeight(1);
  strokeJoin(ROUND);
  fill(30,27,34,220);
  rect(left,top,right-left,bottom-top);

  fill(200,200,200);
  image(reload_image,width/2-30*pix,bottom-90*pix,80*pix,80*pix);
  setTextSize(32*pix);
  textAlign(CENTER,TOP);
  drawText(challenges[iChallenge].cheating_message,left+10*pix,top+10*pix,right-left-20*pix);
}

void mousePressedInCheatingDetectedMode()
{
  // reload the challenge, go to the settings screen
  cheating_detected = false;
  is_settings_mode = true;
  reloadChallengeKeepingExistingReactions();
}

void saveReactions()
{
  if(is_js_version) return; // saveStrings doesn't work in JS

  String reactions_as_strings[] = new String[reactions.size()];
  for(int i=0;i<reactions.size();i++)
  {
    Reaction r = (Reaction)reactions.get(i);
    reactions_as_strings[i] = r.asString();
  }
  saveStrings(challenges[iChallenge].id+".txt",reactions_as_strings);
}

void loadReactions()
{
  reactions.clear();

  if(is_js_version) return; // loadStrings doesn't work in JS

  String reactions_as_strings[] = loadStrings(challenges[iChallenge].id+".txt");
  if(reactions_as_strings == null)
    return; // fail silently (file may not exist, that's OK)

  for(int i=0;i<reactions_as_strings.length;i++)
  {
    reactions.add(new Reaction(reactions_as_strings[i]));
  }
}

void goToURL(String url) // (here as a function in case we need to add functionality)
{
  link(url);
}

void onBackPressed()
{
  if(showing_atoms_area_help)
   showing_atoms_area_help = false;
  else if(is_settings_mode)
    backButtonPressedInSettingsMode();
  else
    exit();
}


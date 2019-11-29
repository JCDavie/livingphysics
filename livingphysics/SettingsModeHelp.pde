float settings_help_scroll_pos=0;
Rect settings_help_ok_button_rect;
float settings_help_excess_height,dragged_settings_help_dialog_y;
boolean is_dragging_settings_help_dialog = false;

void showSettingsHelp()
{
  float left = 40*pix;
  float right = width-left;
  float top = -1;
  float bottom = height-top;
  float internal_border = 5*pix;
  
  String text_block1;
  if(iChallenge==0)
    text_block1 = "This panel shows the current challenge and the reactions.\n\nIn this challenge you don't need to change any reactions, so you can just hit the tick symbol to close the panel.";
  else
    text_block1 = "This panel shows the current challenge and the reactions.\n\n"+
      "You can drag the panel up and down if the contents are not all visible.\n\n"+
      "In the 'Reactions' section you can click on a reaction to edit it, and there are two buttons: to delete all the reactions (will ask to confirm) and to add a new reaction.\n\n"+
      "At the bottom is a clipboard button that allows you to change levels if you get stuck or want to go back to a previous challenge.\n\n"+
      "A reload button allows you to restart the current challenge (will ask to confirm), keeping the reactions as they are.\n\n"+
      "You can dismiss the panel (and this one) with the tick button.";
  
  settings_help_ok_button_rect = new Rect((left+right)/2-40*pix,bottom-90*pix,80*pix,80*pix);
  setTextSize(28*pix);
  float text_height = textHeight(text_block1,right-left-internal_border*2);
  float y1 = settings_help_ok_button_rect.y-internal_border*4;
  float y2 = settings_help_ok_button_rect.y-internal_border*2;
  
  float panel_height = top+internal_border*2+text_height+20*pix+(height-y1);
  settings_help_excess_height = max(0, panel_height - height);

  if(is_dragging_settings_help_dialog)
  {
    settings_help_scroll_pos += dragged_settings_help_dialog_y-pointerY;
    dragged_settings_help_dialog_y = pointerY;
  }
  settings_help_scroll_pos = constrain(settings_help_scroll_pos,0,settings_help_excess_height);
  
  fill(0,0,0,100);
  rect(0,0,width,height);
  stroke(230,140,100);
  strokeWeight(1);
  strokeJoin(ROUND);
  fill(30,27,34);
  rect(left,top,right-left,bottom-top);
  
  textAlign(LEFT,TOP);
  fill(255,255,255);
  drawText(text_block1,left+internal_border,top+internal_border*2-settings_help_scroll_pos,right-left-internal_border*2);
  
  fill(30,27,34,200);
  noStroke();
  rect(left+1,y1,right-left-2,height-y1);
  fill(30,27,34);
  noStroke();
  rect(left+1,y2,right-left-2,height-y2);
  settings_help_ok_button_rect.drawImage(tick_image);
  
  if(settings_help_excess_height>0)
  {
    // show the scroll position
    stroke(200,200,200,200);
    strokeWeight(3*pix);
    float scroll_height = height*height/panel_height;
    float scroll_y = (height-scroll_height)*settings_help_scroll_pos/settings_help_excess_height;
    line(right+6*pix,scroll_y,right+6*pix,scroll_y+scroll_height);
  }
}

void pointerPressedInSettingsHelpMode()
{
  // exit if on ok button
  if(settings_help_ok_button_rect.contains(pointerX,pointerY))
  {
    showing_settings_help = false;
  }
  // otherwise start scrolling
  else if(settings_help_excess_height>0)
  {
    // start dragging the dialog contents up and down
    is_dragging_settings_help_dialog = true;  
    dragged_settings_help_dialog_y = pointerY;
  }
}

void pointerReleasedInSettingsHelpMode()
{
  is_dragging_settings_help_dialog = false;
}


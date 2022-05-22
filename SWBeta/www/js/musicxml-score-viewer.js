var osmd;
var cursor;
var i = -1;
var last_scroll_position = -1;

var current_measure = 1;

var resize_timer;
var current_layout = "horizontal";
var vertical_top_height = 0;
var vertical_bottom_height = 0;
var horizontal_left_width = 0;
var horizontal_right_width = 0;
var range;

var score_render_is_ready = false;
var LastSelectedMeasure = -1;

var select_with_mouse = false;
var select_with_mouse_first_measure = -1;
var select_with_mouse_last_measure = -1;

var select_with_mouse_first_measure_time = -1;
var select_with_mouse_last_measure_time = -1;

var select_with_mouse_LastX = -1;
var select_with_mouse_LastY = -1;
var select_with_mouse_Began = false;

var timestamp_Json_Array = [];


var current_zoom = 2;

//----------------------------------------------------------------------------------------------------------------
function draw_measure_indicator(scroll_into_view) {
  console.log("draw_measure_indicator");

  if (!score_render_is_ready) {
    jQuery(".CurrentCursorSelected").remove();
    return;
  }
  if (current_measure < 1) {
    jQuery(".CurrentCursorSelected").remove();
    return;
  }

  if (current_measure <= osmd.graphic.measureList.length) {
//    console.log(current_measure);
//    console.log(osmd.graphic.measureList[current_measure - 1]);


    var x1 = osmd.graphic.measureList[current_measure - 1][0].boundingBox.absolutePosition.x * 10 * osmd.zoom;
    var y1 = osmd.graphic.measureList[current_measure - 1][0].boundingBox.absolutePosition.y;// + osmd.graphic.measureList[current_measure][0].boundingBox.boundingMarginRectangle.y;

    var width = osmd.graphic.measureList[current_measure - 1][0].boundingBox.borderRight * 10 * osmd.zoom;

    if (osmd.graphic.measureList[current_measure - 1].length > 1) {
      var height =
        ((osmd.graphic.measureList[current_measure - 1][(osmd.graphic.measureList[current_measure - 1].length - 1)].boundingBox.absolutePosition.y +
          4) -
          y1) * 10 * osmd.zoom;
    }
    else {
      var height = 4 * 10 * osmd.zoom;
    }
    y1 = y1 * 10 * osmd.zoom;

    jQuery(".CurrentCursorSelected").remove();
    jQuery("#osmdContainer").append('<div class="CurrentCursorSelected" style="pointer-events: none; position: absolute; background-color: rgba(255,128,128,0.3); left:' + x1 + 'px; top:' + y1 + 'px; width:' + width + 'px; height: ' + height + 'px;"></div>');


    if (scroll_into_view) {
      if (last_scroll_position >= (y1 - 100) && last_scroll_position <= (y1 - 40)) { //&& jQuery('#osmdContainer').scrollTop() >= (y1 - 120) && jQuery('#osmdContainer').scrollTop() <= (y1 - 40)
      }
      else {
        last_scroll_position = y1 - 80;
        jQuery('#osmdContainer').animate({
          scrollTop: y1 - 80
        }, 100);
      }
    }
  }
}


//----------------------------------------------------------------------------------------------------------------
function measure_where_mouse_is(relX, relY) {
  console.log("measure_where_mouse_is");

  var jj = osmd.graphic.measureList.length;
  for (var i = 0; i < jj; i++) {
    // console.log ( i+" "+ osmd.graphic.measureList[i].length );
    var x1 = osmd.graphic.measureList[i][0].boundingBox.absolutePosition.x * 10 * osmd.zoom;
    var y1 = osmd.graphic.measureList[i][0].boundingBox.absolutePosition.y;// + osmd.graphic.measureList[i][0].boundingBox.boundingMarginRectangle.y;

    var width = osmd.graphic.measureList[i][0].boundingBox.borderRight * 10 * osmd.zoom;

    if (osmd.graphic.measureList[i].length > 1) {
      var y3 = osmd.graphic.measureList[i][(osmd.graphic.measureList[i].length - 1)].boundingBox.boundingRectangle.height;
      if (y3 < 5) {
        y3 = 5;
      }
      var height =
        ((osmd.graphic.measureList[i][(osmd.graphic.measureList[i].length - 1)].boundingBox.absolutePosition.y +
          y3) -
          y1) * 10 * osmd.zoom;
    }
    else {
      var height = osmd.graphic.measureList[i][0].boundingBox.boundingRectangle.height * 10 * osmd.zoom;
    }
    y1 = y1 * 10 * osmd.zoom;

    if (relX >= x1 && relX <= (x1 + width) && relY >= y1 && relY <= (y1 + height)) {
      return i + 1; //return 1 index instead of 0 index
      break;
    }
  }
  return -1;

}


//----------------------------------------------------------------------------------------------------------------
function highlight_selected_blocks() {
  console.log("highlight_selected_blocks");

  jQuery(".SelectedBlocks").remove();
  var jj = osmd.graphic.measureList.length;
  var temp_select_with_mouse_first_measure = select_with_mouse_first_measure;
  var temp_select_with_mouse_last_measure = select_with_mouse_last_measure;

  if (select_with_mouse_first_measure > select_with_mouse_last_measure) {
    temp_select_with_mouse_first_measure = select_with_mouse_last_measure;
    temp_select_with_mouse_last_measure = select_with_mouse_first_measure;
  }

  for (var i = 0; i < jj; i++) {
    if (i >= (temp_select_with_mouse_first_measure - 1) && i <= (temp_select_with_mouse_last_measure - 1)) {

      var x1 = osmd.graphic.measureList[i][0].boundingBox.absolutePosition.x * 10 * osmd.zoom;
      var y1 = osmd.graphic.measureList[i][0].boundingBox.absolutePosition.y;// + osmd.graphic.measureList[i][0].boundingBox.boundingMarginRectangle.y;

      var width = osmd.graphic.measureList[i][0].boundingBox.borderRight * 10 * osmd.zoom;

      if (osmd.graphic.measureList[i].length > 1) {
        var height =
          ((osmd.graphic.measureList[i][(osmd.graphic.measureList[i].length - 1)].boundingBox.absolutePosition.y +
            4) -
            y1) * 10 * osmd.zoom;
      }
      else {
        var height = 4 * 10 * osmd.zoom;
      }
      y1 = y1 * 10 * osmd.zoom;

      jQuery("#osmdContainer").append('<div class="SelectedBlocks" style="pointer-events: none; position: absolute; background-color: rgba(128,255,128,0.3); left:' + x1 + 'px; top:' + y1 + 'px; width:' + width + 'px; height: ' + height + 'px;"></div>');
    }
  }
}


//----------------------------------------------------------------------------------------------------------------
function attach_mouse_events_to_sheet() {
  console.log("attach_mouse_events_to_sheet");

  jQuery("#osmdCanvasPage1").on('click', function (ev) {
    var parentOffset = jQuery(this).offset();
    var relX = ev.pageX - parentOffset.left;
    var relY = ev.pageY - parentOffset.top;

    console.log("X: " + relX + " Y: " + relY);

    var WhichMeasure = measure_where_mouse_is(relX, relY);
    if (WhichMeasure !== -1) {

      var temp_current_measure = current_measure;
      current_measure = WhichMeasure;
      draw_measure_indicator(false);

      for (var i = 0; i < timestamp_Json_Array.length; i++) {
        if (timestamp_Json_Array[i].measure === current_measure) {

          //window.webkit.messageHandlers.iOSNative.postMessage({'ClickMeasure' : current_measure, 'TimeStamp': timestamp_Json_Array[i].timestamp });
					window.webkit.messageHandlers.iOSNative.postMessage((timestamp_Json_Array[i].timestamp).toString())
          break;
        }
      }
    }
  });


  //highlighing code
//   jQuery("#osmdCanvasPage1").on('mousedown', function (ev) {
//     select_with_mouse = true;
//     select_with_mouse_Began = false;

//     var parentOffset = jQuery(this).offset();
//     var relX = ev.pageX - parentOffset.left;
//     var relY = ev.pageY - parentOffset.top;
//     select_with_mouse_LastX = relX;
//     select_with_mouse_LastY = relY;

//   });

//   jQuery("#osmdCanvasPage1").on('mousemove', function (ev) {

//     var parentOffset = jQuery(this).offset();
//     var relX = ev.pageX - parentOffset.left;
//     var relY = ev.pageY - parentOffset.top;
//     var WhichMeasure;

//     if (select_with_mouse) {

//       if (relX >= (select_with_mouse_LastX - 5) && relX <= (select_with_mouse_LastX + 5) &&
//         relY >= (select_with_mouse_LastY - 5) && relY <= (select_with_mouse_LastY + 5)) {

//       }
//       else {
//         if (!select_with_mouse_Began) {
//           select_with_mouse_first_measure = -1;
//           select_with_mouse_last_measure = -1;
//         }

//         select_with_mouse_Began = true;
//         if (select_with_mouse_first_measure === -1) {
//           jQuery(".SelectedBlocks").remove();
//           WhichMeasure = measure_where_mouse_is(relX, relY);
//           if (WhichMeasure !== -1) {
//             select_with_mouse_first_measure = WhichMeasure;
//           }
//         }


//         select_with_mouse_LastX = relX;
//         select_with_mouse_LastY = relY;
// //        console.log("X: " + relX + " Y: " + relY);

//         WhichMeasure = measure_where_mouse_is(relX, relY);
//         if (WhichMeasure !== -1) {
//           select_with_mouse_last_measure = WhichMeasure;
//         }
//         highlight_selected_blocks();
//       }
//     }
//   });

//   jQuery("#osmdCanvasPage1").on('mouseup', function (ev) {
//     if (select_with_mouse) {
//       console.log("selected range: " + select_with_mouse_first_measure + " " + select_with_mouse_last_measure);

//       if (select_with_mouse_Began) {
//         jQuery("#loop_button").attr("src", "https://scorewind.com/sw-music/musicxml/images/loop3_selected.png");

//         for (var i = 0; i < timestamp_Json_Array.length; i++) {
//           if (timestamp_Json_Array[i].measure === select_with_mouse_first_measure) {
//             select_with_mouse_first_measure_time = timestamp_Json_Array[i].timestamp;
//           }
//           if (timestamp_Json_Array[i].measure === select_with_mouse_last_measure) {
//             select_with_mouse_last_measure_time = timestamp_Json_Array[i + 1].timestamp;
//           }
//         }

//         highlight_selected_blocks();
//       }
//       select_with_mouse = false;
//     }
//   });
}


//----------------------------------------------------------------------------------------------------------------
function render_sheet_again() {
  console.log("render_sheet_again");

  if (!score_render_is_ready) {
    console.log("render_sheet_again stopped as score is not ready");
    return;
  }

  jQuery("#osmdContainer").css({"height": (jQuery("window").height()) + "px", "width": (jQuery("window").width()-200) + "px"});

  clearTimeout(resize_timer);
  jQuery("#loading_div").css({"display": "flex"});
  jQuery("#loading_div").show();
  resize_timer = setTimeout(function () {
    osmd.render();
    jQuery("#loading_div").fadeOut();
//    jQuery("#osmdContainer").append('<div id="hightlight_bar" style="pointer-events: none; position: absolute; top:0px; left:0px; width: 1px; height: 1px;"></div>\n');
    draw_measure_indicator(true);
    attach_mouse_events_to_sheet();
    highlight_selected_blocks();
  }, 100);
}



//----------------------------------------------------------------------------------------------------------------
function load_score_view(LocalXMLFile) {
  timestamp_Json_Array = Local_timestamp_data;
  for (var i = 0; i < timestamp_Json_Array.length; i++) {
    //timestamp_Json_Array[i].id_ts = Number(timestamp_Json_Array[i].id_ts);
    timestamp_Json_Array[i].measure = Number(timestamp_Json_Array[i].measure);
    timestamp_Json_Array[i].timestamp = Number(timestamp_Json_Array[i].timestamp);
  }

  // jQuery("#loop_button").on('click', function () {
  //   select_with_mouse_first_measure = -1;
  //   select_with_mouse_last_measure = -1;
  //   highlight_selected_blocks();
  //   jQuery("#loop_button").attr("src", "https://scorewind.com/sw-music/musicxml/images/loop3.png");
  // });




        // var endTimestamp = 0;
        // for (var i = 0; i < timestamp_Json_Array.length; i++) {

        //   end_timestamp = timestamp_Json_Array[i].timestamp + 100;
        //   if (i < timestamp_Json_Array.length - 1) {
        //     end_timestamp = timestamp_Json_Array[i + 1].timestamp;
        //   }

        //   if (video_current_time >= timestamp_Json_Array[i].timestamp && video_current_time < end_timestamp) {
        //     current_measure = timestamp_Json_Array[i].measure;
        //     jQuery("#tooltip_current_measure").html(current_measure);
        //     draw_measure_indicator(true);
        //     break;
        //   }
        // }


  osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay("osmdContainer");
  osmd.setOptions({
    backend: "svg",
    autoResize: false,
    drawTitle: false,
		alignRests: 2 
    // drawingParameters: "compacttight" // don't display title, composer etc., smaller margins
  });
  osmd.load(LocalXMLFile).then(
    function () {

      score_render_is_ready = true;
      osmd.zoom = current_zoom;

      console.log(osmd);
      console.log(osmd.graphic.measureList);
      console.log(osmd.graphic.measureList[0][0].boundingBox);

      render_sheet_again();

      // cursor = osmd.cursor;
      // cursor.show();
    }
  );

}

function zoomIn(zoom_action) {
  if (zoom_action==="Zoom In") {
    current_zoom += 0.2;
  } else
  {
    current_zoom -= 0.2;
  }
  osmd.zoom = current_zoom;
  render_sheet_again();
}

<?php
/*
   This project is copyright 2012 Wayne and Layne, LLC.
   Source code is licensed under the GPL v2 license.
   Everything else (graphics, html, media, etc.) is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License: http://creativecommons.org/licenses/by-sa/3.0/

   For more details about the blinky kits, please check out:
   http://www.wayneandlayne.com/projects/blinky/
*/
$new_div_raw = "
<table border=\"0\" cellpadding=\"4\" cellspacing=\"0\">
    <tr>
        <td style=\"vertical-align: top;\">
            <img src=\"move.gif\" alt=\"Move\" title=\"Move\" class=\"move\" id=\"msg_' + num + '_handle\" /><br /><br />
            <a href=\"#\" onclick=\"delete_message(' + num + ');\"><img src=\"delete.png\" alt=\"Delete\" title=\"Delete\" class=\"delete\" /></a>
        </td>
        <td style=\"vertical-align: top;\">
            <strong>Type:</strong>
            <label for=\"msg_' + num + '_type_text\"><input type=\"radio\" name=\"msg_' + num + '_type\" id=\"msg_' + num + '_type_text\" value=\"text\" checked=\"checked\" onclick=\"change_message_type(' + num + ');\"/>Text</label>
            <label for=\"msg_' + num + '_type_pixel\"><input type=\"radio\" name=\"msg_' + num + '_type\" id=\"msg_' + num + '_type_pixel\" value=\"pixel\" onclick=\"change_message_type(' + num + ');\" />Pixel</label>&nbsp;&nbsp;-&nbsp;&nbsp;
            
            <strong>Style:</strong>
            <label for=\"msg_' + num + '_anim_marq\"><input type=\"radio\" name=\"msg_' + num + '_anim\" id=\"msg_' + num + '_anim_marq\" value=\"marq\" checked=\"checked\" />Marquee <img src=\"msg_marq.gif\" alt=\"Marquee\" title=\"Marquee\" width=\"16\" height=\"24\" style=\"vertical-align: middle;\"/></label>
            <label for=\"msg_' + num + '_anim_anim\"><input type=\"radio\" name=\"msg_' + num + '_anim\" id=\"msg_' + num + '_anim_anim\" value=\"anim\" />Animation <img src=\"msg_anim.gif\" alt=\"Animation\" title=\"Animation\" width=\"16\" height=\"24\" style=\"vertical-align: middle;\"/></label><br />
            
            <strong>End behavior:</strong> <select id=\"msg_' + num + '_end_type\"><option value=\"0\">Stop</option><option value=\"1\">Repeat this message</option><option value=\"2\" selected=\"selected\">Advance to next message</option><option value=\"3\">Easter egg...</option></select>&nbsp;&nbsp;&nbsp;<strong>Delay:</strong> <select id=\"msg_' + num + '_delay\"><option value=\"0\">0</option><option value=\"1\">1</option><option value=\"2\">2</option><option value=\"3\">3</option><option value=\"4\">4</option><option value=\"5\">5</option><option value=\"6\">6</option><option value=\"7\" selected=\"selected\">7</option><option value=\"8\">8</option><option value=\"9\">9</option><option value=\"10\">10</option><option value=\"11\">11</option><option value=\"12\">12</option><option value=\"13\">13</option><option value=\"14\">14</option><option value=\"15\">15</option></select>
            
            <hr />

            <div id=\"msg_' + num + '_text\" style=\"display: block;\">Message:<input type=\"text\" size=\"15\" style=\"font-weight: bold; font-size: 20px;\" id=\"msg_' + num + '_text_message\" value=\"Hello World\" /><br />Available characters: 0-9, A-Z, !, ?, &amp;, \',\', and \'.\'.</div>
           
            <div id=\"msg_' + num + '_pixel\" style=\"display: none;\">
                Click to set LEDs. Click X to remove column. <input type=\"button\" onclick=\"add_led_col(' + num + ');\" value=\"Add Column\" />
                <div id=\"msg_' + num + '_pixel_leds\">
                </div>
            </div>
        </td>
    </tr>
</table>";

$token = strtok($new_div_raw, "\n");
$new_div = "";
while ($token != false)
{
    $new_div .= $token;
    $token = strtok("\n");
}

$led_line = "";
for ($i = 0; $i < 8; $i++)
    $led_line .= "<img src=\"led_dark.png\" onclick=\"toggle_led(this);\" /><br />";
$led_line .= "<img src=\"led_x.png\" onclick=\"delete_led_column(this);\" />";
?>

<html>
<head>
<title>Blinky POV and Blinky GRID Programming</title>
<link rel="stylesheet" type="text/css" href="drag.css" />
<script type="text/javascript" src="SOTC-DnDLists.js"></script>
<script type="text/javascript">

function toggle_led(led)
{
    if (transmitting == 0) // not currently transmitting
    {
        if (led.src.indexOf("dark") != -1)
            led.src = "led_lit.png";
        else
            led.src = "led_dark.png";
    }
}

function delete_led_column(col)
{
    var my_parent_div = col.parentNode;
    my_parent_div.parentNode.removeChild(my_parent_div);
}

// adds a new column of leds to the specified message
function add_led_col(which, left)
{
    var d = document.getElementById("msg_" + which + "_pixel_leds");
    var new_col = document.createElement("div");
    new_col.setAttribute("style", "float: left; width: 16px;");
    new_col.innerHTML = '<?= $led_line ?>';
    if (left)
        d.insertBefore(new_col, null); // add it to the start - TODO make this work
    else
        d.insertBefore(new_col, null); // add it to the end

    // TODO check if we've finished a new block of seven columns and add a vertical thing - also have to handle it on removal!
    /*
    var sep = document.createElement("img");
    sep.setAttribute("src", "white.png");
    sep.setAttribute("style", "float: left; width: 1px; height: 128px");
    d.insertBefore(sep, null);
    */
}


var num_messages = 0; // this var is only used to ensure that we have uniquely named items as we add more messages
var message_drag_objects = Array();

function add_new_message()
{
    var num = num_messages.toString();
    var new_div = document.createElement("DIV");
    new_div.className = "list";
    new_div.setAttribute("id", "msg_" + num);
    new_div.setAttribute("style", "height: 250px;");
    new_div.innerHTML = '<?= $new_div ?>';
    List.insertBefore(new_div, null);
    for (var i = 0; i < 7; i++)
        add_led_col(num, 0); // add columns of leds to the message's pixel section
    message_drag_objects[num_messages] = new dragObject("msg_" + num, "msg_" + num + "_handle", null, null, itemDragBegin, itemMoved, itemDragEnd, false);
    num_messages += 1;
}

function delete_message(which)
{
    if (which >= message_drag_objects.length)
    {
        alert("Trying to delete a message with id > number of messages! Something went seriously wrong. Please tell wayneandlayne@wayneandlayne.com what you were trying to do!");
    }
    if (confirm("Are you sure you want to delete this message?"))
    {
        message_drag_objects[which].Dispose();
        List.removeChild(document.getElementById("msg_" + which));
    }
}

// TODO add up/down buttons on mobiles to allow them to re-order messages

function change_message_type(which)
{
    var div_text = document.getElementById("msg_" + which + "_text");
    var div_pixel = document.getElementById("msg_" + which + "_pixel");
    if (document.getElementById("msg_" + which + "_type_text").checked)
    {
        div_text.style.display = 'block';
        div_pixel.style.display = 'none';
    } else {
        div_text.style.display = 'none';
        div_pixel.style.display = 'block';
    }
}

// -------------------------------------------------------------------
// These functions are used to do the actual creation of the transmission data,
// and encapsulate them into message messages and the intel-hex-like wrapper.

// These two arrays store our data to transmit, in two different forms:
var message_data;   // an array of byte values to transmit, including the message wrapper data (this is exactly what we want to be in eeprom)
var xmit_data;      // an array of byte values that should be transmitted via blinky protocol. it is message_data after it has been partitioned and checksummed into our intel-hex-like wrapper format.
var xmit_raw;       // an array of 0/1 values, generated from xmit_data

function dec2hex(i)
{
      var result = "00";
      if      (i >= 0    && i <= 15) {result = "0" + i.toString(16);}
      else if (i >= 16   && i <= 255){result = ""  + i.toString(16);}
      else {alert("Invalid value for dec2hex: " + i + ". Returning '00'.");}
      return result.toUpperCase();
}

// these two functions add byte values into the message_data
// message config byte (byte 0 of each message):
//  7       pixel=1, text=0
//  6       flashy=1, marquee=0 (grid only)
//  5-2     delay, low is fast, high is slow
//  1-0     end type, 
// TODO are the foo=1, bar=0 items above accurate?
// byte 1 is the number of data bytes
function handle_message_text(which)
{
    message_data.push(make_config_byte(which, 0x00)); // text message has bit 7 = 0
    font_table = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.!&?, ";
    var text = document.getElementById("msg_" + which + "_text_message").value.toUpperCase();
    var num_chars = 0;
    var this_data = Array();
    for (var i = 0; i < text.length; i++)
    {
        var c = font_table.indexOf(text[i]);
        if (c == -1)
        {
            alert("Invalid character detected in font message '" + which + "': '" + text[i] + "'. It will be ignored.");
        }
        else
        {
            this_data.push(c);
            num_chars++;
        }
    }

    message_data.push(num_chars);
    for (var i = 0; i < num_chars; i++)
        message_data.push(this_data[i]);
}
function handle_message_pixel(which)
{
    message_data.push(make_config_byte(which, 0x80)); // pixel message has bit 7 = 1

    var columns = document.getElementById("msg_" + which + "_pixel_leds").getElementsByTagName("div");
    if (document.getElementById("msg_" + which + "_anim_anim").checked)
        num_data_bytes = 7 * Math.ceil(columns.length / 7);
    else
        num_data_bytes = columns.length;
    message_data.push(num_data_bytes);
    for (var c = 0; c < columns.length; c++)
    {
        var leds = columns[c].getElementsByTagName("img");
        var data = 0;
        for (var l = 0; l < leds.length; l++)
        {
            if (leds[l].src.indexOf("lit") != -1)
            {
                data |= (1 << (7-l)); // TODO here is where we figure out the endianness stuff, so check here if things are upside down or whatever
            }
        }
        message_data.push(data);
    }

    if (document.getElementById("msg_" + which + "_anim_anim").checked)
    { // for flashy mode, we have to pad out to even blocks of seven
        for (var i = 0; i < (7 - (columns.length % 7)) % 7; i++)
            message_data.push(0x00);
    }
}

// this function crafts a config byte based on the settings picked by the user
function make_config_byte(which, config_byte)
{
    if (document.getElementById("msg_" + which + "_anim_anim").checked)
        config_byte |= 0x40;
    var msg_delay = parseInt(document.getElementById("msg_" + which + "_delay").value);
    config_byte |= ((msg_delay & 0x0F) << 2);
    var end = parseInt(document.getElementById("msg_" + which + "_end_type").value);
    config_byte |= end;
    return config_byte;
}

// takes data from message_data and wraps it up into 16-byte chunks with a record type, address, data length, and checksum
// stores output in the xmit_data array
// it's similar to the intel hex file format, except without hex-ascii encoding the data first (transmit raw binary values)
function wrap_messages()
{
    // we reverse the message_data array so we can just pop things off the end
    message_data.reverse();

    xmit_data = Array();
    var addr_hi = 0;
    var addr_lo = 0;
    var record_type = 6;
    while (message_data.length > 0)
    {
        var num_bytes = Math.min(message_data.length, 16); // can transmit a max of 16 bytes per record
        var checksum = 0;
        xmit_data.push(num_bytes);      checksum += num_bytes;
        xmit_data.push(addr_hi);        checksum += addr_hi;
        xmit_data.push(addr_lo);        checksum += addr_lo;
        xmit_data.push(record_type);    checksum += record_type;
        for (var j = 0; j < num_bytes; j++)
        {
            var value = message_data.pop();
            xmit_data.push(value);      checksum += value;
        }
        xmit_data.push((256 - (checksum & 255)) & 255); // checksum is whatever is needed to bring the current checksum to 0x00
        addr_lo += num_bytes;
    }

    // add the final "please reset the device" record
    xmit_data.push(0x00);
    xmit_data.push(0x00);
    xmit_data.push(0x00);
    xmit_data.push(0x01);
    xmit_data.push(0xFF);

    // now, the proper byte values are stored in xmit_data
}

// converts the byte values in xmit_data into a raw binary bitstream of 0/1 values
// stores output in the xmit_raw array
function encode_xmit_data()
{
    xmit_raw = Array();
    for (var i = 0; i < xmit_data.length; i++)
    {
        for (var j = 7; j >= 0; j--)
        {
            if (xmit_data[i] & (1 << j))
                xmit_raw.push(1);
            else
                xmit_raw.push(0);
        }
    }
}

// this function is called by the "stop" button
function stop_dump()
{
    transmitting = 0;
    document.getElementById("progressImg").width = 0;
    document.getElementById("progressSpan").innerHTML = "Canceled";
}

// this function is called by the "go" button, and starts everything off
function start_dump()
{
    if (transmitting == 0) // not currently transmitting
    {
        message_data = Array();
        var num_messages = 0;
        var items = List.getElementsByTagName("div");
        for (var i = 0, n = items.length; i < n; i++)
        {
            var item = items[i];
            if (item.getAttribute("class") == "list")
            {
                var id = item.id.split("_")[1];
                if (document.getElementById("msg_" + id + "_type_text").checked)
                {
                    // this is a text message - put bytes into message_data
                    handle_message_text(id);
                }
                else
                {
                    // this is a pixel message - put bytes into message_data
                    handle_message_pixel(id);
                }
                document.getElementById("message_data").value = message_data;
                num_messages++;
            }
        }
        if (num_messages > 0)
        {
            // we found at least one message to transmit
            message_data.unshift(num_messages);
            document.getElementById("message_data").value = message_data;
            var hex = Array();
            for (var i = 0; i < message_data.length; i++)
                hex.push(dec2hex(message_data[i]));
            document.getElementById("message_data_hex").value = hex;
            
            wrap_messages(); // converts data from message_data to xmit_data
            document.getElementById("xmit_data").value = xmit_data;
            hex = Array();
            for (var i = 0; i < xmit_data.length; i++)
                hex.push(dec2hex(xmit_data[i]));
            document.getElementById("xmit_data_hex").value = hex;

            encode_xmit_data(); // converts data from xmit_data to 0/1 stored in xmit_raw
            document.getElementById("xmit_raw").value = xmit_raw;

            // do the actual blinking transmission
            index = 0;
            transmitting = 1;
            delay = document.getElementById("delay").value;
            setTimeout('set_data()', delay);
        }

    } // else we are currently transmitting, ignore the button press
}

// some variables relating to the actual blinky transmission
var delay; // milliseconds - selectable from webpage
var index; // how far we are in transmitting the xmit_raw array
var current_clock = 0;
var transmitting = 0; // 1 when we are currently transmitting, so don't let the user update anything
var progress_max_width = 301;

// Sets the color of the clock div. Pass in a valid css/html color name like "white" or "black".
function set_color_clock(c)
{
    e = document.getElementById("divclock");
    e.style.backgroundColor = c;
}
// Sets the color of the data div. Pass in a valid css/html color name like "white" or "black".
function set_color_data(c)
{
    e = document.getElementById("divdata");
    e.style.backgroundColor = c;
}


// These two functions call each other (alternating) using setTimeout().
function set_data()
{
    // this function sets the color of the data panel based on the raw 0/1 values in xmit_raw (indexed by the variable 'index')
    if ( (transmitting == 1) && (index < xmit_raw.length) ) // the stop button sets transmitting = 0.
    {
        if (xmit_raw[index] == 0)
            set_color_data("black");
        else
            set_color_data("white");
        index++;

        // record progress - not added because it's too difficult
        /*
        var byte_ix = index / 8;
        if (xmit_raw.length - index <= (8 * 21))
            var progress = 0; // at the end of transmission
        else
            var progress = (byte_ix % 21) / 21; // in the middle of transmission
        document.getElementById("recordProgressImg").width = progress_max_width * progress;
        document.getElementById("recordProgressSpan").innerHTML = Math.round(100 * progress) + "%";
        */

        // overall progress
        var progress = index / xmit_raw.length;
        var seconds_remaining = Math.round(((xmit_raw.length - index) * (delay * 2)) / 1000.0);
        document.getElementById("progressImg").width = progress_max_width * progress;
        document.getElementById("progressSpan").innerHTML = Math.round(100 * progress) + "% (" + seconds_remaining + "s left)";

        setTimeout('toggle_clock()', delay);
    } else {
        // all finished
        set_color_clock("black");
        set_color_data("black");
        transmitting = 0;
    }
}
function toggle_clock()
{
    // this function toggles the color of the clock panel each time it is called
    if (current_clock == 0)
    {
        current_clock = 1;
        set_color_clock("white");
    } else {
        current_clock = 0;
        set_color_clock("black");
    }

    setTimeout('set_data()', delay);
}

// this function from http://msdn.microsoft.com/en-us/library/ms537509%28v=vs.85%29.aspx
function getInternetExplorerVersion()
// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
{
  var rv = -1; // Return value assumes failure.
  if (navigator.appName == 'Microsoft Internet Explorer')
  {
    var ua = navigator.userAgent;
    var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
    if (re.exec(ua) != null)
      rv = parseFloat( RegExp.$1 );
  }
  return rv;
}

disp_ie_message = none;
</script>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-1965415-2']);
  _gaq.push(['_setDomainName', '.wayneandlayne.com']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</head>
<body>
<h1>Blinky POV and Blinky GRID Programming</h1>
<p>This webpage will let you design and upload new messages to your <a href="http://www.wayneandlayne.com/projects/blinky/">Blinky POV</a> or <a href="http://www.wayneandlayne.com/projects/blinky/">Blinky GRID</a> kit. First, you should create one or more messages in the first section below. Once your messages are prepared, section 2 below will let you transmit the new message(s) to your Blinky kit.</p>
<div id="ie_message" style="display: none;">
<strong>Internet Explorer users:</strong> The blinky programming website doesn't work with IE, so you need to use another browser. We've had great luck with Firefox and Chrome, along with the Android and iOS browsers. Sorry for the inconvenience!<br /><a href="http://www.mozilla.org/en-US/firefox/fx/"><img src="get_firefox.png" width="175" height="68" border="0" /></a>&nbsp;&nbsp;&nbsp;<a href="https://www.google.com/chrome"><img src="get_chrome.png" width="175" height="68" border="0" /></a>
</div>
<h2>1. Create Messages</h2>
<p>You can store multiple messages on your Blinky kit. Messages can be either text-based or pixel-based. Font-based messages take up much less memory than pixel-based messages. Marquee/Animation only matters on Blinky GRID. For delay, 0 is the fastest value and 15 is the slowest value. Drag the arrow icons to reorder your messages. Use the garbage can to remove a message.</p>
<div id="list" style="position: relative; border: 1px solid white; width: 575px;">
</div>
<input type="button" onclick="javascript: add_new_message();" value="Add New Message" />
<!-- TODO add some buttons like "Add @" and "Add heart" eventually. -->
<script type="text/javascript">
load();
add_new_message(); // start out with one message
if (getInternetExplorerVersion() != -1)
{
    document.getElementById("ie_message").style.display = "block";
}
</script>
<h2>2. Programming</h2>
<p>Enter programming mode: Hold down the button while turning on the power switch. Release the button. Hold the Blinky up to the screen. Be sure to align the sensors correctly: The sensor labeled C points to clock, and D points to data. Press and release the button when you're ready to begin transmission. Press the Go button to start.</p>
<p><a href="/files/blinky/images/programming_animated_gif/blinky_programming.gif"><img src="/files/blinky/images/programming_animated_gif/blinky_programming_crop.png" width="375px" height="194px" border="0"><br /><strong>Check out this awesome animated guide to programming!</strong></a></p>
<p><strong>Please note!</strong> On 2011/09/10 we switched the locations of the clock and data squares below to make it easier to hold the Blinky device while programming, based on customer feed back we have received over the past few months. This requires no change in the Blinky firmware, only a change in how you align the sensors on the screen. Please <a href="/contact/">let us know</a> if this change is a dealbreaker.</p>
<div style="width: 620px;">
    <div style="float: right; width: 301px; padding-left: 10px;">
        <br /><div style="width: 301px; height: 30px; border: 2px solid white; position: relative;">
            <img src="progress_bar_30px_tall.png" height="30" width="1" id="progressImg" style="position: absolute; top: 0; left: 0; z-index: -1;" />
            <div style="padding: 5px;">Progress: <span id="progressSpan"></span></div>
        </div>
        <br />
        <table border="0" cellspacing="2" cellpadding="2">
        <tr><td><input type="button" onClick="javascript:start_dump();" style="height: 50px; width: 60px; font-size: 100%; font-weight: bold;" value="Go" /></td><td>
        <input type="button" onClick="javascript:stop_dump();" style="height: 50px; width: 60px; font-size: 100%; font-weight: bold;" value="Stop" /></td>
        <td>Delay (ms):<br /><input type="text" size="4" id="delay" value="40" /></td></tr></table>
    </div>
    <div style="width: 301px; background-color: white; border: 2px solid white;">
        <div id="divdata" style="width: 150px; height: 150px; background-color: black; float: right;">Data</div>
        <div id="divclock" style="width: 150px; height: 150px; background-color: black;">Clock</div>
    </div>
</div>
<h2>3. Troubleshooting</h2>
<p>For the delay value, smaller values equal quicker data transmissions, but too small/fast might cause errors! The smallest reliable value depends on your monitor, browser, and computer graphics hardware. Start with a value of 40, and make sure it can reliably transfer your messages. You can then gradually reduce the delay time until you start having invalid transmissions, indicated by alternating flashing of the third and fourth LEDs on your Blinky board. We've have good luck with values of 25-40 on various systems we've tested.</p>
<p>During normal transmission, the second LED will flash once for each byte of data received. When the transmission is finished, the blinky should immediately start displaying your messages. The blinky data is transmitted as a series of one or more <em>records</em>. After each record is transmitted, the blinky will double-check the data to make sure it was properly transmitted (using something called a <a href="http://en.wikipedia.org/wiki/Checksum">checksum</a>). If the checksum is invalid, meaning that there was a data transmission problem, the third and fourth LEDs on the blinky will flash rapidly in an alternating pattern. If this happens, press the Stop button, reset your blinky into the programming (bootloader) mode, and try again. If you continue to experience trouble, try increasing the value in the delay box and set your monitor's brightness to 100%. If nothing works, try the <a href="/forum/">forums</a>.</p>

<div style="display: <?= (isset($_GET['debug'])) ? 'block' : 'none' ?>;">
<hr>
<strong>Debug information:</strong><br />
message_data:<br />
<textarea id="message_data" cols="60" rows="5"></textarea><br />
message_data hex:<br />
<textarea id="message_data_hex" cols="60" rows="5"></textarea><br />
<br />
xmit_data:<br />
<textarea id="xmit_data" cols="60" rows="5"></textarea><br />
xmit_data hex:<br />
<textarea id="xmit_data_hex" cols="60" rows="5"></textarea><br />
<br />

<br />
xmit_raw:<br />
<textarea id="xmit_raw" cols="60" rows="5"></textarea>
</div>
</body>
</html>

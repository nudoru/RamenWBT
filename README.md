This is a draft of my internal documentation of the project. It is a little out of date from the final feature set but gives a good over view.

Here is a demo of Scientia http://mattperkins.me/learningportfolio/ramen/index.html


About the Scientia Player
=========================
Matt Perkins, 7-31-09

Scientia is a framework to quickly and easily create full Flash courses. You don’t need a Flash developer to create courses with Scientia – anyone familiar with XML or HTML can develop with it! Scientia is fully themable so that it can adapt the desired look and feel of the learning solution. It includes several common screen types to create eye catching interactions and provides an easy programming interface so that an advanced Flash developer can create new interactions quickly and easily. Scientia has a robust set of object types (images, text areas, buttons, etc.) and actions so that custom interactions may be created in XML alone – saving developers time.

Scientia communicates with any SCORM 1.2 or SCORM 2004 compliant LMS ensuring that training records are updated accurately and according to industry standards. Basic tracking information is recorded and advanced information, such as interaction data, is planned.

Authors of any skill level can quickly deliver a full course by using their favorite XML editor and image editing software. Courses can be authored using the included templates and features of the player so that you never need to open Flash or create a single line of code.

Advanced Flash developers can “get their hands dirty” and take advantage of the easy to use programming interfaces and create new course themes or interactions. There is no limit to the types of training you can create!

**Framework features**

- Small files sizes
-- The framework files, themes and templates are designed to be small for swift download on limited bandwidth connections
- The user interface for a course is fully themable
-- Change the background, header, page area, navigation, menu, color scheme and fonts. You can create a library of approved themes and swap them effortlessly – even after the course has been created!
- Text formatting supports using CSS (cascading style sheets)
- Supports section 508 accessibility features
-- Text size may be increased or decreased according to user preference
-- Courses and templates are fully navigable with the keyboard
- Page to page transition – fade or out squeeze in the next page when navigating within a course
- Course structure is defined in an XML file. This makes it very easy to reorder, add or remove pages
- All page content is stored in XML files giving your content the following benefits:
-- Small files sizes
-- Easy to repurpose the data since it’s separated from the content
-- Easy to translate since it’s plain text
-- Enables reuse of the page templates – one page template SWF file can utilize an unlimited number of content XML files
- LMS Integration is optional – any content created will also work as a standalone web site
- “Full browser flash” – the interface may be centered or align to any side of the browser window
- SWFAddress is available if LMS tracking is not used – allows for forward and backward navigation using the browser’s navigation – works just like a traditional HTML based web site! Also allows for linking and bookmarking (deep linking) directly to any page in the course
- SWFObject is used to embed the player in the HTML page – industry standard solution to ensure maximum compatibility between browsers and platforms
- Utilizes the Pipwerks SCORM JavaScript and Flash framework for maximum LMS compatibility – a widely tested and used code base to ensure the tracking will work perfectly
- Variable completion status
-- view any page (complete on launch)
-- view the last page (useful for branching situations)
-- view all pages
- Force passing and treat a failing status as incomplete
- Variable number of tries for all interactions
- “Scored” interactions that count towards the overall course score and require answering before you can progress

**Included** **page** **templates**

As of July 2009, the follow prebuilt interaction templates are included. Many template options are configurable in the page’s XML which allows them to be as flexible as possible without requiring adjustments in Flash.

[cut]

Creating new interactions is an easy task for a Flash developer. A new interaction may be built off of an existing one or quickly created from scratch using the programming interface provided by Scientia.

**Page objects**

Page objects are on screen items that may be to customize a page’s appearance and add extra functionality.

- Text areas (may scroll)
- Text box (may scroll)
- Shapes – lines, rectangles, rounded corner rectangles, circles and ellipses
- Images (GIF, JPG and PNG) 
- Flash animations (any type of SWF file)
- Hotspots
- Audio player (on road map)
- Flash video (FLV) player (on roadmap)
- Complex object – custom coded Flash object created by a Flash developer
- Event manager – invisible object for controlling actions on multiple items

Scientia takes advantage of the advanced display technologies of the Flash player. Any of the support blend modes or filters can be applied to any object and images can even be distorted to simulate perspective. Utilizing these features in a course will save time since specialized graphic or text treatments will be created in the player, **not** in Photoshop.

Descriptions of the blend modes can found on Adobe’s web site by clicking [here](http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/display/BlendMode.html).

Supported filters include:
- Blur – blur in both the X and Y axis
- Glow
- Drop shadow
- Desaturate – make a color graphic black and white
- Saturate – enhances the colors in a graphic

**Page object transitions** 

The appearance of page objects on the screen can be animated with transitions. The available transitions:
fade_in
bright_in
bright_in_flicker
slide_from_left
slide_from_right
drop_from_top
fall_off
zoom_out
subtle_top
subtle_left
subtle_right
subtle_bottom

**Page objects actions**

To create custom functionality, with no new page template creation, the Scientia framework allows you to apply XML driven “programming” to page objects. These actions may occur when an object is first shown, after a certain period of time or when a learner interactions when them.

- Animated fly ins (13 types are included as of now, more are easy to add)
- Animated fly outs 
- Go to a web site
- Go to a page in the course
- Control a Flash animation (SWF) file object on the page (gotoAndPlay, gotoAndStop)
- Control a movie clip in a Flash animation on the page
- Show or hide another page object
- Open a popup window
- Send a command to a complex object
- Change the page’s status
- _Change the course’s status_ _(planned)_

**Popup Windows**

Scientia supports several types of dragable popup windows:
- Message with a title bar
- Message with an icon
- Correct/Incorrect
- Scrolling
- “Lightbox” (for displaying a large image fullscreen)
- Custom containing page objects

Popups may be created from the template or from a page object action.

**LMS and Tracking information**

Currently, only basic information is sent to the LMS. This includes:
- Completion status: incomplete, complete and passed or failed (if the course is scored, an optional setting)
- Score (if the course is scored, an optional setting)
- Time spent in the course
- Bookmark

Internally Scientia tracks on a page level and remembers the status of each page. This is recorded to the LMS when you exit and pages are returned to this state when you resume the course. This means that Scientia remembers if you answered a question incorrectly or not and if you completed interactions on the page between attempts on the course.

If there is no LMS present, Scientia can also track progress locally to the learner’s hard drive. This is useful for a CD ROM based course.

**Custom variable and XML driven programmatic logic** **– “Logic”**

Currently in development, Scientia is evolving a system where developers can create and modify their own variables as the learner interacts with the course. Developers may also utilize predefined framework variables, such as the current page number, progress complete, and the learner’s current score. These will drive a simple logic system (if/ then/else) that will cause the player to perform actions similar what page objects can do. 

Logic may be on a page and also be at the course level and run each time a lesson is accessed or a page is shown. The number of times the Logic action runs may also be specified.

**Developer and authoring features**

Scientia offers a few common features to help developers troubleshoot their work during development and after deployment:
- Running log of what the framework and LMS is doing behind the scenes
- Warning and error popup messages
- Memory footprint graph – identify buggy templates and assets that may cause browser crashes
- “Cheat mode” – bypasses page locks and set the course complete with a score of 100. This is also very useful for the help desk if a bug causes the learner to be stuck and unable to complete a course.

Since there is no WYSIWYG environment, the framework provides a quick mouse tool to help position and size objects on a page with pixel perfect accuracy.


Programming / Developer Guide
=============================

RAMEN Elearning and Web Site Framework
_Last updated_ _3.13.09_

What is it?

Ramen is a framework that facilitates the easy creation of custom Flash based web sites and learning modules. Customizable XML is used for site’s structure, basic settings and content. Visual and functional customization is available via “themes” and modification of the framework’s source code.

Files

The main Ramen code folder is divided up into 2 main directories: “source” and “deploy.” The source directory contains all of the FLA and AS files. The deploy directory is the contains the compiled SWF files, XML documents and other assets that make up the deliverable.

**Sample deploy directory**

File/directory
**Description**
**Ramen.swf**
The Ramen player file.
**_Assets directory_**
Contains images and other media assets used by the site.
**_Classes directory_**
Contains AS3 class files used by the player source code.
**_Embed directory_**
Files used by SWFAddress and SWFObject
**_Resources directory_**
Customizable user interface elements and a library of available themes
**_Templates directory_**
Page template SWF files
**_Xml directory_**
Contains the site.xml file and XML files for the site’s pages

The Ramen player follows the MVC design pattern. The page templates may not follow this pattern depending on the implementation of the individual templates.

**Some of the class files that make up the framework**

Class file
**Description**
**Ramen.as**
The controller class for the player. Also the document class for the ramen.fla file.
**SiteModel.as,** **NodeModel.as,** 
The data model classes for the player. These represent the site structure as defined by the site.xml file. Pages are also represented in the NodeModel.
**AbstractView.as**
The abstract view class for the player. All site views must extend this class.
**CenteredView.as**
The default view of the site. Aligns the site page area as defined in the site.xml file and the size of the browser window.
**PageLoader.as**
Loads the currently selected page’s SWF file.
**RamenTemplate.as**
Abstract document class for a page SWF file. All pages must extend this class.
**PageRenderer.as**
Loads and parses the XML file for the page. Displays simple text in the text fields, displays page objects.
**PageObject.as**
Parent class for a page object. Every type of page object extends this class.
***.as**
Page objects and page object support files.
***Event.as**
Custom events


Themes and Customizing the UI

Most of the site’s look, feel and behavior may be changed by editing an existing theme or creating a new one.

Themes are located in the “resources” directory and consist of the following files:

Resource File*
**Description**
**theme.xml**
Settings for the theme
**shared_resources.swf**
Contains shared resources used by the Ramen UI – main menu buttons, pop up windows, icons, etc.
**ui_bg.swf**
Background the user interface area – header, page background, etc.
**background.swf**
Background of the site. Two samples are provided – one that scales to the browser window, one that tiles a bitmap image to fill the space.
**overlay.swf**
Graphic that overlays on the whole page area of the interface.
**navigation.swf**
Contains the main menu and any other site navigation.
**audio_bg.swf**
Background audio file. Currently not supported.
**audio_sfx.swf**
Sound effects. Currently not supported.
**fonts.swf**
Fonts used by dynamic text areas. Calibri must be in this file since it is used by several classes to create dynamic text fields. Other fonts may be added as required for the project.

*The name for each files is specified in the theme.xml file.

The site configuration/structure file

The site’s configuration and structure is controlled by the xml/site.xml file. 

**Description**
**Example**
Site information
<!-- Define metadata for the site -->
<meta>
	<title>Player Development</title>
	<version>1</version>
	<lastupdate>09.02.21</lastupdate>
	<author>Matt Perkins</author>
	<notes></notes>
</meta>
Site configuration
<!--configuration data -->
<config>
	<!-- use keyboard navigation and controls in the player -->
	<useplayerkeycommands>true</useplayerkeycommands>
	<!-- show a pop up on player warning - useful for debugging during development -->
	<showwarnings>true</showwarnings>
	<!-- sound effects enabled? true or false -->
	<sfxenabled>false</sfxenabled>
	<!-- background audio enabled? true or false -->
	<sbgenabled>false</sbgenabled>
	<!-- use SWFAddress for deeplinking? should turn off for use on an LMS -->
	<swfaddressenabled>true</swfaddressenabled>
	<!-- theme settings file -->
	<themefile>resources/stdwbt/theme.xml</themefile>
</config>
LMS configuration
<lms>
	<!--
		none - LMS disabled
		scorm
			*scorm2004
	-->
	<mode>none</mode>
	<!-- DEBUGGING TESTING FEATURE!!! -->
	<simulatelms>false</simulatelms>
	<!--
		entrance
		view_last_page
			*view_all_pages
			*manual - completion set by a POEvent on a page
			*mastery_score
			*mastery_score&allow_fail
			*mastery_score&view_all_pages
			*mastery_score&view_all_pages&allow_fail
	-->
	<completioncriteria>view_last_page</completioncriteria>
	<!-- scoring features not yet implimented -->
	<masteryscore>80</masteryscore>
	<!-- number of required attempts on scored interactions -->
	<intr_numtries>1</intr_numtries>
	<!-- forect correct answer -->
	<intr_forceca>true</intr_forceca>
	<!-- exit prompt to display if the module isn't completed yet -->
	<exitpromptnoncomplete><![CDATA[Are your sure you want to exit?<br><br>Your progress will be saved and you may return to the module anytime.<br><br>]]></exitpromptnoncomplete>
	<!-- exit prompt to display if the module is completed -->
	<exitpromptcomplete><![CDATA[Are your sure you want to exit?<br><br>Your progress will be saved.<br><br>]]></exitpromptcomplete>
</lms>
Site structure
<!-- 
define the site structure 
	names and ID's MUST BE UNIQUE! navigation will not work correctly if there are identical names
	nodes are major groups - must contain pages. cannot nest a node inside of another. think of these as main menu items
	toc  = true/flase, these nodes should not show on any menu structure
	scored true/flase, these notes will be treated special
-->
<structure>
	<module id="root" name="root">
		<node id="chapter1" name="Chapter 1">
			<page id="ch1_pg1" toc="true" name="Page 1" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
			<page id="ch1_pg2" toc="true" name="Page 2" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
			<page id="ch1_pg3" toc="true" name="Page 3" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
		</node>
		<node id="chapter2" name="Chapter 2">
			<page id="ch2_pg4" toc="true" name="Page 4" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
			<page id="ch2_pg5" toc="true" name="Page 5" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
			<page id="ch2_pg6" toc="true" name="Page 6" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
		</node>
		<node id="chapter3" name="Chapter 3">
			<page id="ch3_pg7" toc="true" name="Page 7" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
			<page id="ch3_pg8" toc="true" name="Page 8" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
			<page id="ch3_pg9" toc="true" name="Page 9" scored="false" swf="templates/generictemplate.swf" xml="xml/default.xml" />
		</node>
	</module>
</structure>

Content Authoring Guide

Template XML

Each page is a SWF file that loads an XML file as specified in the site.xml file. 

Description
Example
Configuration information for the page
<config>
	<!-- name of the page -->
	<name>Testing Page</name>
	<!-- type of page -->
	<type>testing</type>
	<!-- size -->
	<pagesize>750,360</pagesize>
	<!-- left, top, right, bottom -->
	<pageborders>10,10,10,10</pageborders>
	<!-- background image for the page -->
	<pagebgimage>assets/pagebg.jpg</pagebgimage>
</config>
Simple content that appears on the page. The 4 text target areas are preprogrammed in to the template and adjusted based on the page size.
<pagecontent>
	<text target="title"><![CDATA[Graphic Page Object]]></text>
	<text target="body"><![CDATA[getlatin:10,20]]></text>
	<text target="bodyleft"><![CDATA[getlatin:100,200]]></text>
	<text target="bodyright"><![CDATA[getlatin:100,200]]></text>
	<image x="50" y="50">assets/testimage.jpg</image>
</pagecontent>
Interaction specific data
<!-- Intearction data here -->
<interaction>
</interaction>
Page objects
<!-- Page Objects go here -->
<sheet>
</sheet>


Sheet and Page Objects

Page objects go in the <customlayout> area of a page. May also be used in certain list item type or nested via the group object type.

**Page Object**
**Notes**
**text**

**textbox**

**shape**
Available shapes: line, rect, roundrect, circle, ellipse
**graphic**
The image is cropped to the specified size.
**gradrect**

**gradroundrect**

**hotspot**

**button**
A SWF file that will with custom states that uses the event system.
**group**
Contains other page objects. Events or transitions on children may not work properly.
**flvplayerbox**
The FLV player objects require a page template that has the FLV player components. This is done to save space in the page template SWF files that do not need this functionality.
**interactiveswf**
The image is cropped to the specified size. Similar to the graphic object, but data in the <objectdata> tag is passed to the SWF once loaded. The SWF should parse this data and use it to configure it self. See the sample “complexposwf.fla” file.
**poaudioplayer**
Uses an external audio player file – see samples.
**eventmanager**
This special type of object is only used to hold only an event list and events for other objects on the same page. Designed primarily for timer events.

Refer to the sample XML files in the xml or xml/examples folder for syntax on individual object types.

Page object transitions

Three transition modes are supported:
- **Automatically playing transition in** – mode set to “play” - Play automatically or with a timed delay when the page is displayed
- **Page object event controlled transition in** – mode set to “stop” - started when an event on another page object tells it to
-- If the page object needs to be initially hidden, set: <start mode="hide"/>
- **Page object event controlled transition out** – mode set to “stop” - started when an event on another page object tells it to.
-- Out mode transitions play the in effect backwards

Available transitions:
show*
hide*
fade_in
bright_in
bright_in_flicker
slide_from_left
slide_from_right
drop_from_top
fall_off
zoom_out
subtle_top
subtle_left
subtle_right
subtle_bottom

* These toggle the visibility and do not animate

Page object events

Page objects may have interactivity such as opening a web site, document or controlling the visibility of another object on the same page. Events are grouped with the <eventlist> tag. Each object may only have one event list. There may be multiple events for each type of action.

- If the object will use events or be targeted by events, it must have a unique id specified. The id is scoped to the page, not the site.
- Objects within a group or list item may not have events.

Events are composed of 6 parts:
1. **Event Id** – unique identifier of the event (scoped to the event list)
1. **Action event** – what will trigger the event. Currently, mouse events are supported:
-- Rollover
-- Rollout
-- Click
-- Release – use of this event is not recommended – currently buggy
-- Timer – occurs with X number of seconds have passed. Timed events may happen every .25 seonds: 0, .25, .5, .75, 1 …
-- Playback – pb_start, pb_play, pb_pause, pb_stop, pb_finish – dispatched from the player object
1. **Time** _– used only for events with_ _an_ _timer action event._ Specifies the time interval when the event occurs
1. **Action result** – what will happen when the event occurs
1. **Target** – what the results acts on, either another page object ID or a document/site location
1. **Data** – any supplemental parameters required by the result


**Action result**
**Target**
**Data**
**goto_url**
Opens this web site in a new browser window
If a mailto link is used, it’s target to “_self” since you don’t need a new window.
n/a
**goto_pageid**
Navigates to this page/node id in the site
n/a
**goto_nextpage**
Navigates to the next linear page
n/a
**goto_prevpage**
Navigates to the previous linear page
n/a
**restart_page**
Reload the current page
n/a
**set_page_status**

The status type to set:
- incomplete
- completed
- passed
- failed
**gotoandstop**
Go to and stop on a frame in this SWF graphic page object
*See targeting below
Frame number or label

**gotoandplay**
Go to and play on a frame in this SWF graphic page object
*See targeting below
Frame number or label

**hide**
ID of page object to hide
n/a
**show**
ID of page object to show
n/a
**toggle**
ID of page object to either show or hide depending on its current state
n/a
**transitionin**
Play the defined in-transition of this page object
n/a
**transitionout**
Play the defined out-transition of this page object
n/a
**playanimation**
ID of the page object
ID of the animation sequence 
**restarttimer**
n/a
n/a
**show_popup**
n/a
n/a, data is contained in the XML data section, see Pop up section for example syntax
**show_popup**
Show the popup as defined in the popup XML contained in the data tag. 

**command**
ID of the page object
Data to use as the command
**dispatchcustomevent**
Name of the event to dispatch to the Ramen class
Parameter of the event

**Targeting with** **gotoandstop** **and** **gotoandplay** **actions**
A movieclip nested on a stage instance may be targeted with the following syntax:
pageobiectid@parent_mc.child_mc.etc...

“parent_mc” is the instance name of a movieclip on the loaded SWFs timeline, “child_mc” is a movieclip on the timeline of the parent. 

Animation sequences _(not working as of 3.1.09)_

Flash CS3 animation sequences may be used to animate page objects. These may be triggered on a page object by using the “playanimation” event targeted on the PO to animate.

**Syntax:**

<animationsequences>
	<animation id=”unique_id”>
		<motion … as copied to the clip board from Flash … />
	</animation>
	…
</animationsequences>

Special treatments to page objects

**Distorting graphic objects**
Graphic objects may be warped by using the <bmdistort> tag. Graphics distorted in this way may not trigger events.

**Syntax:**
<!-- tl, bl, tr, br -->
<bmdistort>0,0;0,350;200,50;200,300</bmdistort>

**Blend mode**
Pos may have one of Flash’s bitmap blendmodes applied. Refer to the Flash documentation for syntax an examples. Note: this does not use AS3’s constants, rather litetal strings like “multiply”

Refer to: [http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/display/BlendMode.html](http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/display/BlendMode.html)

**Syntax:**
<blendmode>multiply</blendmode>

**Bitmap filters**
Several predefined bitmap filters may be applied to  objects:
blur – blur in both the X and Y axis
glow
shadow – drop shadow
desaturate – turns an graphic black and white, requires no other parameters
saturate – requires no other parameters

**Syntax:**
<bmfilter type="type">
	<color>0x000000</color>
	<angle>45</angle>
	<distance>2</distance>
	<alpha>.3</alpha>
	<blur>10</blur>
<blurx>10</blurx>
<blury>10</blury>
	<strength>10</strength>
</bmfilter>

Pop Up Windows

Pop up windows may be initiated from page object events or from the template page in response to a user event. The look of all pop ups are determined based on the sprites in the _shared_resources.swf_ file.

A pop up may be modal or persistent. If it’s modal the entire site UI is disabled until the popup is dismissed. Typically, all pop ups are dismissed when the user navigates to a new page. A persistent popup remains until the user closes it. 

**NOTE:** A pop up cannot be both modal and persistent. Modal will take precedence.

By default pop ups will appear centered in the browser window (middle, center). Valid properties for controlling the position of the pop up are:

**Horizontal**
left
center
right
**Vertical**
top
high_middle
middle
low_middle
bottom

**NOTE:** When the browser window is resized, the pop up will auto align to maintain its position. If the pop up is draggable, then it will remain where the user places it, losing the auto align functionality.

**NOTE:** Each pop up should have a unique ID. Only one pop up with that ID will be allowed on the screen at a time.

**Syntax:**
<popup id=”id” draggable=”true|false”>
	<type modal=”true|false” persistant=”true|false”>type</type>
	<title>text</title>
	<content><![CDATA[text]]></content>
	<icon>icon name</icon>
<size>width,height</size>
	<hpos>center</hpos>
	<vpos>middle</vpos>
	<buttons>
		<button event=”close” data=”data”>OK</button>
	</buttons>
	<custom>
		… TBD …
	</custom>
</popup>

**Example syntax in PO Element event:**
<event id="click" actionevent="click" actionresult="show_popup" target="" data="">
	<data>
		<popup id="testpopup" draggable="true">
			<type modal="false" persistant="false">simple</type>
			<title>Pop up title</title>
			<content><![CDATA[Popup text]]></content>
			<hpos>center</hpos>
			<vpos>middle</vpos>
			<buttons>
				<button event="close" data=”player_next”>Dismiss</button>
			</buttons>
		</popup>
	</data>
</event>

**Types of Pop ups**

**Name**
**Description**
**Supported Properties**
**simple**


**icon**


**lightbox**
Show an image or animation over the UI

**custom**
Unsupported – future

**feedback_correct**


**feedback_incorrect**


**feedback_neutral**


**custom**



**Button events**

**Name**
**Description**
**Supported Properties**
**Ok**
Unsupported - future

**Cancel**
Unsupported - future

**Close**
Closes the pop up window and runs the action specified by data

**Quit**
Unsupported - future

**Yes**
Unsupported - future

**No**
Unsupported - future

**data**
Unsupported - future


**Button event data**

A data attribute of the button tag will pass a command to the player or pass a command to the current page template. 

**Commands for the player** 

**NOTE:** all begin with “player_”

**Name**
**Description**
**nextpage**

**prevpage**

**jumpto%pageid**

**refreshpage**

**exitmodule**

**setpage-incomplete**

**setpage-completed**

**setpage-passed**

**setpage-failed**


**Opening a popup from a page object event**

<object type="button" id="button1" guid="">
	<position>10,50</position>
	<size>100,22</size>
	<url>assets/button1.swf</url>
	<eventlist>
		<event id="over" actionevent="rollover" actionresult="" target="" data="" />
		<event id="out" actionevent="rollout" actionresult="" target="" data="" />
		<event id="click" actionevent="click" actionresult="show_popup" target="" data="">
			<data>
				<popup id="testpopup" draggable="true">
					<type modal="false" persistant="false">simple</type>
					<title>Passing data back to the page template</title>
					<content><![CDATA[getlatin:50,100]]></content>
					<hpos>middle</hpos>
					<vpos>high_center</vpos>
					<buttons>
						<button event="close" data="blah">Dismiss</button>
					</buttons>
				</popup>
			</data>
		</event>
		<event id="release" actionevent="release" actionresult="" target="" data="" />
	</eventlist>
</object>


Accessibility Features

The framework provides a tab key support and hot key support for many common actions. 

Supported hot keys are:

**Framework**
- left arrow - back
- right arrow - next
- home - go to menu (if there is one)
- end - display exit prompt
- esc - close top most popup window
- ctrl+shift+1 - display debug information panel

**Page template level**
- Any key not trapped by the framework is passed to the page template. I plan on using these:
- up/down arrow - auto select prev/next items in list
- a-z - select answer choices in questions
- enter - commit choice 

Pressing the tab key will cycle between all of the available “clickable” items on the screen (including screen content). When designing custom templates and themes, the developer may make items available by using the AccessibilityManager class.

**Syntax**
AccessibilityManager.getInstance().addActivityItem(_object, name,_ _shortcut_key,_ _long_description_)

There are 3 “layers” of tab indexes. Layers are segmented so that interactive objects maybe assigned a different times
- Activity items: 1-29
- Media: 30-49
- Framework: 50-onward

**Notes:** due to inconsistencies with how Flash handles the enter key press and triggering mouse events, the framework employees a “virtual mouse” to “click” on the items when the enter key is press. The location of this mouse is at x+1, y+1 to the object that has focus.



Programming Guide

Templates and theme files control the player by dispatching events. These take advantage of the display list bubbling of AS3. 

Disabling main navigation buttons from a page template 

Use the NavigationUIEvent from a page and the player will pass a command to the navigation.swf file with the type of event and the target data. The navigation.swf file should act on this command. Since key bindings will be affected by the enable or disabling of certain buttons, constants are provided for the next and back buttons. The player will detect these events and enable and disable the key bindings for those functions.

The navigation file may be customized to accept any button name or parameter for the event data.

**Syntax:**
dispatchEvent(new NavigationUIEvent(NavigationUIEvent._TYPE_, "_target_"));

**Event types:**
- BTN_ENABLE
- BTN_DISABLE
- BTN_HIDE
- BTN_SHOW
- BTN_TOGGLE

**Button constants:**
- NEXT_BTN
- BACK_BTN

**Examples:**

To disable the next button:
dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_DISABLE, NavigationUIEvent.NEXT_BTN));
To enable the next button:
dispatchEvent(new NavigationUIEvent(NavigationUIEvent.BTN_ENABLE, NavigationUIEvent.NEXT_BTN));

Events broadcast by Ramen engine

 Sound effects may be tied to these or other programmatic events. These are captured and handled in the Ramen class.

Events:
page_loaded
page_unloaded
main_menu_rollover_event
main_menu_rollout_event
main_menu_selection
page_menu_rollover_event
page_menu_rollout_event
page_menu_selection
po_rollover_event
po_rollout_event
po_click_event
po_custom&eventtarget_eventdata*

*This event may be triggered by any page object <event>. 


Variables

Variables may be defined by the developer in the site or page XML file (not supported as of 4-16-09) by using a logic tag or one of the predefined variables in the framework.

**Predefined variables**

**Name**
**Description**
courseVarCurrentScore
The current score obtained by the learner
CourseVarIsPassing
“true” if the learner is passing the course
courseVarIsComplete
“true” if the learner has met the completion criteria as defined in the site.xml file
courseVarAllPagesViewed
“true” if the learner has viewed/completed every page in the course
lmsVarStudentName
The normalized name of the student as returned from the LMS system. Normalization turns a name from “Smith,John” to “John Smith.” If no LMS connection is present, the name will be “Student Name.”
lmsVarStudentID
The learner ID as returned from the LMS system. If no LMS connection is present, the ID will be “xxx000.”
**Showing variables in page text**

Variables may shown in most page text areas (area's that support AutoContent functionality): page and pop-up titles and body text areas, text page objects and in template specific text areas. 

Example syntax: Hello there, {$lmsVarStudentName$}, welcome to the training!

Logic

The framework contains an XML defined “scripting” system for reacting to variables and setting variable contents. These consist primarily of set variable actions or if/then blocks. There may only be 1 logic tag get item, mulitple logic blocks are not supported.

**Syntax:**
<logic id=”unique_id” maxoccur=”number”>
	…
</logic>

The id attribute must be unique to the XML file that contains the logic section – site.xml or page xml file. The maxoccur attribute set the maximum number of times the logic action run. If blocks only increment this when evaluated to true.

**SET: Creating a new variable or setting an existing variable value**

_Note: this is a planned feature and is unsupported as of 4-16-09._

**Syntax:**
<set persist="false">
	<variable>variable_name</variable>
	<value>val</value>
</set>

If the variable doesn't exist, then a new variable is created with the specified value. Setting persist to “true” causes the variable to be stored in the course's suspend_data.

**IF: Responding to a variable or condition**

**Syntax:**
<if>
	<variable>courseVarIsPassing</variable>
	<compare>equal</compare>
	<to>true</to>
	<then>
		<action>alert</action>
		<target></target>
		<data><title>Course is done!</title><content>You Passed!</content></data>
	</then>
</if>

**DO and THEN**

_Note: The THEN portion of an IF block acts as a standalone DO block._

**Syntax:**
	<do> or <then>
		<action>...</action>
		<target>...</target>
		<data>...</data>
	</do> or </then>

**Description**
**Action**
**Target**
**Data**
Go to a new page
goto
The ID of the target page
n/a
Show a simple pop-up message
alert
n/a
<title>title</title>
<content>content</content>
Display a pop-up
popup
n/a
Standard popup XML

**Using Logic on Pages and Page objects**
Note: This is not supported yet.
**Using Logic in the site.xml file**
A logic block may be specified in the site.xml file on the module, section, topic or page level. These blocks execute upwards from the page level after the page content is loaded and a rendered event has been dispatched. 


Player Error Codes

**Warnings**
Code
Description
00000
Unspecified

**Errors**
Code
Description
10000
Unspecified

**Fatal**
Code
Description
20000
Unspecified

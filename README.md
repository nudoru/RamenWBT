This is a draft of my internal documentation of the project. It is a little out of date from the final feature set but gives a good over view.

Here is a demo of Scientia http://mattperkins.me/learningportfolio/ramen/index.html

I have authoring/developer documentation that I plan to upload soon also.

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

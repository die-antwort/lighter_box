# LighterBox

A very lightweight lightbox with a bare minimum of features, packaged for the Rails asset pipeline:

 * Displays a single image (with caption) or arbitrary content loaded via Ajax.
 * Fully accessible (note that all UI alt texts and titles are in german).
 * Gallery mode (navigation between related images / contents).
 * Fullscreen mode for small screen devices (see below).
 * Supports nested lightboxes.

On small screen devices the lightbox will be shown fullscreen, with a fixed header bar containing the close button (and gallery buttons, if applicable). Per default this mode is activated for screens narrower than 480px (can be customized by setting `$lighter-box-fullscreen-breakpoint` before importing the Sass file).

## Requirements

Requires a recent jQuery version (may work with Zepto, too).

Designed to work with current browsers (including minor workarounds to make sure it’s not completely broken in IE9).


## Installation

Add `lighter_box` to your Gemfile. Use sprockets directives to include the code in your JS/CSS:

```javascript
//= require "lighter_box"
```

```sass
@import "lighter_box"
```


## Usage

Create a new instance of `LighterBox.Ajax` or `LighterBox.Image`, with the link element referencing the target image or content as parameter.

A common pattern is to do this in a event handler like this:

```coffee
$("body").on "click", "a[data-lightbox]", (ev) ->
  ev.preventDefault()
  if $(this).data("lightbox-mode") == "ajax"
    new LighterBox.Ajax(this)
  else
    new LighterBox.Image(this)
```


### Configuration via attributes

The following attributes on the source element (link) can be used to customize LighterBox:

 * `data-lightbox-class`: Additional css class names for the lightbox modal.
 * `data-lightbox-group`: Used for gallery mode: Next / previous links will be displayed to allow navigation between lightboxes for source elements that share the save value for this attribute. Hidden source elements are ignored, so the gallery mode works well with all sorts of client side filtering. Note that this feature relies on jQuery’s `:visible` selector, which might yield unexpected results (eg. for links wrapping block elements, see https://github.com/jquery/jquery/issues/2227).
 * `data-lightbox-href`: The URL that to be loaded into the lightbox. If not set, the link’s `href` attribute is used. If used with an image lightbox, this URL must also point to an image (common usecase: the link points to the original image file, but the lightbox should display a smaller version of the image instead).

Image lightbox only:

 * `data-lightbox-caption`: Image caption. If not set, the image’s alt text is used as caption.
 * `data-lightbox-caption-allow-html`: If present, the image caption is interpreted as HTML.

Ajax lightbox only:

 * `data-lightbox-fragment`: A jQuery selector to specify the portion of the remote document to be loaded into the lightbox (similar to the fragment feature of [`jQuery.load()`](http://api.jquery.com/load/)).


### Events

The following events will be triggered on the lightbox modal element:

 * `lighter-box-content-loaded`: When the content has been completely loaded (lightbox already visible).
 * `lighter-box-will-hide`: Before the lightbox elements (modal, container and backdrop) are removed from the DOM.

Event handlers will get passed the lightbox instance as second parameter (after the event object).


### Styling

Depending on your site’s CSS you may need specify a custom `z-index` value for lightbox and backdrop. Set `$lighter-box-z-index` to an appropriate value before importing the styles.

There are some more variables that can be customized, see `lib/assets/stylesheets/lighter_box.sass` for a full list.


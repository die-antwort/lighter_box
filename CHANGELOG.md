# v1.0.0
 * Remove workarounds and polyfills for legacy browsers.
 * Use vanilla CSS instead of Sass (removes dependency on the sass gem).

# v0.6.0
 * Add ability to customize the z-index value for lightbox and backdrop (via Sass variable `$lighter-box-z-index`).
 * Fix border radius on close button (set by user agent stylesheets e.g. in Chrome).

# v0.5.0
 * Option `data-lightbox-href` can now also be used for image lightboxes.

# v0.4.0
 * New fullscreen mode for small screen devices.
 * Close button is now positioned outside the lightbox, resulting in a larger click target and more consistent placement with the previous/next links in gallery mode Also, the close button is now already visible when the lightbox content is loading, allowing the user to abort the loading process. (Technically this has already been possible by simply clicking on the backdrop, but this is not really discoverable from an UX standpoint).

# v0.3.2

* Gallery mode: Ignore hidden source elements. This makes the gallery mode compatible with all sorts of client side filtering. As a side effect, the list of source elements used for gallery mode is now determined at the moment the lightbox is openend (in earlier versions it was determined when lighter box was initialized).

# v0.3.1

* Reset margins and padding for `figure` element used in image lightboxes (some CSS frameworks – eg. Bootstrap – apply non-zero margins to `figure` elements by default).

# v0.3.0

* New option `data-lightbox-href` for ajax lightboxes: Allows to override the URL to be loaded into the lightbox (default is the link’s `href` attribute).

# v0.2.0

* New option `data-lightbox-caption-allow-html` for image lightboxes: Allows the image caption to be interpreted as HTML.

# v0.1.1

* Fix “fragment” feature of ajax lightbox not always working.
* Fix missing css style definition
* Improve readme.

# v0.1.0

* Initial version

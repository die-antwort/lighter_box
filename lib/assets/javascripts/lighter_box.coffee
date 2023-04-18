class Backdrop
  constructor: ->
    @isNestedBackdrop = $(".lighter-box-backdrop").length > 0
    @backdrop = $("<div class='lighter-box-backdrop' />").appendTo("body")
    unless @isNestedBackdrop
      $("body").addClass("lighter-box-has-backdrop")
      $("body > *").wrapAll("<div class='lighter-box-aria-hide-body' aria-hidden='true' />")

  remove: =>
    @backdrop.remove()
    unless @isNestedBackdrop
      $(".lighter-box-aria-hide-body > *").unwrap()
      $("body").removeClass("lighter-box-has-backdrop")



class Spinner
  constructor: (@parentEl) ->
    @el = $("<div class='lighter-box-spinner' tabindex='0'><div class='lighter-box-sr-only'>wird geladen …</div><div class='rect1' /><div class='rect2' /><div class='rect3' /><div class='rect4' /><div class='rect5' /></div>").hide().appendTo(@parentEl)
    @delay = null

  showDelayed: (delayMS) =>
    @_clearDelay()
    @delay = window.setTimeout(@show, delayMS)

  show: =>
    @_clearDelay()
    @el.show().focus()

  remove: =>
    @_clearDelay()
    @el.remove()
    @parentEl.focus()

  _clearDelay: =>
    window.clearTimeout(@delay)



class LightboxGroup
  constructor: (@currentEl) ->

  index: =>
    @_elems().index(@currentEl)

  hasNext: =>
    @index() + 1 < @_elems().length

  hasPrev: =>
    @index() - 1 >= 0

  nextHref: =>
    @_elems().eq(@index() + 1).attr("href")

  prevHref: =>
    @_elems().eq(@index() - 1).attr("href")

  next: =>
    @currentEl = @_elems().eq(@index() + 1)

  prev: =>
    @currentEl = @_elems().eq(@index() - 1)

  _elems: =>
    if (groupName = @currentEl.attr("data-lightbox-group"))
      $("[data-lightbox-group='#{groupName}']:visible")
    else
      @currentEl


class ImageModalResizer
  MIN_CAPTION_WIDTH: 200

  constructor: (@modal) ->
    @figure     = @modal.find("figure")
    @img        = @figure.find("img")
    @figcaption = @figure.find("figcaption")
    @minImgHeight = parseInt(@img.css("min-height"), 10)
    @running = false

  run: =>
    return if @running
    @running = true
    window.requestAnimationFrame(@_run)

  _run: =>
    @img.css("max-height": "none")
    @modalHeight = @modal.height()
    @_resize()
    @running = false

  _resize: =>
    if (overflow = @figure.height() - @modalHeight) > 0
      if (newHeight = @img.height() - overflow) >= @minImgHeight
        @img.css("max-height": "#{newHeight}px")
      else
        @img.css("max-height": "#{@minImgHeight}px")
        return # Make sure we don't recurse any more
    captionWidth = Math.max(@img.width(), @MIN_CAPTION_WIDTH)
    @figcaption.css("max-width": captionWidth)
    @_resize() if @figure.height() > @modalHeight



class LighterBox
  constructor: (srcEl) ->
    @eventNamespace = "lighter-box-#{new Date().getTime()}"
    @srcEl = $(srcEl)
    @originalFocusEl = $(":focus")
    @lightboxGroup = new LightboxGroup(@srcEl)
    @backdrop = new Backdrop()
    @container = @_createContainer()
    @modal = @_createModal(@container)
    @modal.addClass(@srcEl.data("lightbox-class")).data("lighter-box", this)
    @_createInnerModal()

    @container.on("click.#{@eventNamespace}", (ev) => @hide() if ev.target == @container[0])
    @container.on("click.#{@eventNamespace}", "[data-lighter-box-dismiss]", @hide)
    @container.on("click.#{@eventNamespace}", "[data-lighter-box-prev]", (ev) => ev.preventDefault(); @_showPrev())
    @container.on("click.#{@eventNamespace}", "[data-lighter-box-next]", (ev) => ev.preventDefault(); @_showNext())
    @container.on("keydown.#{@eventNamespace}", @_onKeydown)
    @_trapFocus()
    @modal.focus()
    @_setContent()

  hide: =>
    @_releaseFocus()
    @container.off(".#{@eventNamespace}")
    $(window).off(".#{@eventNamespace}")
    @modal.trigger("lighter-box-will-hide", [this])
    @container.remove()
    @backdrop.remove()
    @originalFocusEl.focus()

  _createContainer: () =>
    $("<div class='lighter-box-container' />").appendTo("body")

  _createModal: (container) =>
    modal = $("<div class='lighter-box-modal' role='dialog' aria-hidden='false' tabindex='0'/>").appendTo(container)
    $("<button class='lighter-box-close-button' title='Vergrößerte Ansicht schließen' data-lighter-box-dismiss><span aria-hidden='true'>×</span></button>").appendTo(container)
    $("<a data-lighter-box-prev class='lighter-box-prev-link' href='#' title='Voriges Bild'><span aria-hidden='true'>‹</span></a>").appendTo(container)
    $("<a data-lighter-box-next class='lighter-box-next-link' href='#' title='Nächstes Bild'><span aria-hidden='true'>›</span></a>").appendTo(container)
    modal

  _createInnerModal: =>
    # Template method, override in subclasses if needed

  _setContent: =>
    prevLink = @container.find("[data-lighter-box-prev]").hide()
    nextLink = @container.find("[data-lighter-box-next]").hide()
    spinner = new Spinner(@modal)
    spinner.showDelayed(100)
    @_loadContent().then =>
      spinner.remove()
      prevLink.attr("href", @lightboxGroup.prevHref()).show() if @lightboxGroup.hasPrev()
      nextLink.attr("href", @lightboxGroup.nextHref()).show() if @lightboxGroup.hasNext()
      @modal.trigger("lighter-box-content-loaded", [this])

  _loadContent: =>
    throw "_loadContent needs to be overriden in a subclass."

  _trapFocus: =>
    $(document).on "focusin.#{@eventNamespace}", (ev) =>
      return unless @_isForemost()
      @modal.focus() unless $.contains(@container[0], ev.target)

  _releaseFocus: =>
    $(document).off "focusin.#{@eventNamespace}"

  _onKeydown: (ev) =>
    return unless @_isForemost()
    switch ev.which
      when 27 then ev.preventDefault(); @hide()
      when 39 then ev.preventDefault(); @_showNext()
      when 37 then ev.preventDefault(); @_showPrev()

  _showNext: =>
    if @lightboxGroup.hasNext()
      @srcEl = @lightboxGroup.next()
      @_setContent()
      @modal.focus()

  _showPrev: =>
    if @lightboxGroup.hasPrev()
      @srcEl = @lightboxGroup.prev()
      @_setContent()
      @modal.focus()

  _isForemost: =>
    @container.nextAll(".lighter-box-container").length == 0



class ImageLighterBox extends LighterBox
  constructor: (srcEl) ->
    super(srcEl)
    @resizer = new ImageModalResizer(@modal)
    $(window).on("resize.#{@eventNamespace}", => @resizer.run())

  _createInnerModal: =>
    figure = $("<figure />").appendTo(@modal)
    $("<figcaption id='lighter-box-figcaption' class='lighter-box-figcaption'/>").appendTo(figure)
    $("<img class='lighter-box-image'>").attr("aria-labelledby": "lighter-box-figcaption").prependTo(figure)

  _loadContent: =>
    $.Deferred (deferred) =>
      href = @srcEl.data("lightbox-href") || @srcEl.attr("href")
      caption = @srcEl.data("lightbox-caption") || @srcEl.find("img").attr("alt") || ""
      newImg = $("<img>").attr(src: href).one "load", =>
        @modal.find("img").attr(src: newImg.attr("src"))
        @_setCaption(caption)
        @resizer.run()
        deferred.resolve()

  _setCaption: (caption) =>
    figcaptionEl = @modal.find("figcaption")
    if @srcEl.data("lightbox-caption-allow-html")
      figcaptionEl.html(caption)
    else
      figcaptionEl.text(caption)
    figcaptionEl.toggleClass("empty-caption", caption.trim() == "")

class AjaxLighterBox extends LighterBox
  constructor: (srcEl) ->
    super(srcEl)

  _createInnerModal: =>
    @ajaxContainer = $("<div/>").appendTo(@modal)

  _loadContent: =>
    href = @srcEl.data("lightbox-href") || @srcEl.attr("href")
    fragment = @srcEl.data("lightbox-fragment")
    $.get href, (data) =>
      data = $("<div/>").append($.parseHTML(data)).find(fragment)
      @ajaxContainer.html(data)



window.LighterBox =
  Ajax: AjaxLighterBox
  Image: ImageLighterBox

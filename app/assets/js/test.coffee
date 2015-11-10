jQuery ->
  pagination = (total, url_prefix, current_page=1, count=10, pages=10) ->
# returns nice bootstrap styled pagination
# pages are 1 indexed

    current_page = parseInt(current_page)
    output = '<div class="pagination"><ul>'

    if (Math.floor(pages / 2)) >= current_page >= 1
      start = 1
    else
      start = current_page - (Math.floor(pages / 2))

    last_page = Math.ceil(total / count)

    # what if total = 0
    if last_page == 0
      last_page = 1

    if last_page >= (start + (pages-1))
      last = start + (pages-1)
    else
      last = last_page

    if (last - start) < (pages-1)
      start = last - (pages-1)
      if start < 1
        start = 1

    # don't show pagination if
    # there is just one page
    if last == start or _.isNaN(last)
      return ''

    if current_page == 1
      onBegining = true
    else
      onBegining = false

    if current_page == last_page
      onEnd = true
    else
      onEnd = false

    if onBegining
      output += '<li class="disabled" data-page="1"><a>&larr;</a></li>'
    else
      output += '<li><a class="scroll-to-top js-page" data-page="1" href="' + url_prefix + '1">&larr;</a></li>'

    for eachpage in [start..last]
      do (eachpage) ->
        if eachpage != current_page
          output += '<li><a class="scroll-to-top js-page" data-page="' + eachpage + '" href="' + url_prefix + eachpage + '">' + eachpage + '</a></li>'
        else
          output += '<li class="active"><a class="scroll-to-top js-page" data-page="' + eachpage + '" href="' + url_prefix + eachpage + '">' + eachpage + '</a></li>'
    if onEnd
      output += '<li class="disabled"><a>&rarr;</a></li>'
    else
      output += '<li><a class="scroll-to-top js-page" data-page="' + last_page + '" href="' + url_prefix + last_page + '">&rarr;</a></li>'

    output += '</ul></div>'
    return output

  trim = (text) ->
    return text.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

  ajaxmsg = (msg, loader=true, autohide=false, timeout=0.5) ->
    $ajaxmsg = $("#ajax-msg")
    if $ajaxmsg.length == 0
      $("body").append('<div id="ajax-msg"><span class="ajax-loader"></span><span class="ajax-msg"></span></div>')
      $ajaxmsg = $("#ajax-msg")
    else
      $ajaxmsg.show()

    if loader
      $ajaxmsg.find('.ajax-loader').addClass('ajax-loading')
    else
      $ajaxmsg.find('.ajax-loader').removeClass('ajax-loading')

    $ajaxmsg.find('.ajax-msg').html(msg)
    $ajaxmsg.css('margin-left', -1*($ajaxmsg.width()/2))

    if autohide
      setTimeout("$('#ajax-msg').hide()", timeout*1000)

  initializeTimers = (text) ->
    for timer in $(".countdowntimer") when $(timer).attr("data-start-time") ? '0000-00-00 00:00:00' and $(timer).attr("data-start-time") isnt " " and $(timer).attr("data-start-time") isnt "0000-00-00 00:00:00"
      do (timer) ->
        t = $(timer).attr("data-start-time").split(/[- :]/)
        $(timer).countdown(
          until: new Date(t[0], t[1]-1, t[2], t[3], t[4], t[5])
          layout: $(timer).attr("data-text") + '{dn} {dl} {hnn}:{mnn}:{snn}'
          timezone: +0.0
          alwaysExpire: true
          onExpiry: ->
            $(this).html($(this).attr("data-done-text"))
            @
        )


  semiFix = (selector, wrapselector) ->
    $(window).scroll ->
      if $(wrapselector).length > 0
        offset = $(wrapselector).offset().top - 40
        scroller_object = $(selector)
        if document.documentElement.scrollTop >= offset or window.pageYOffset >= offset
          if $.browser.msie and $.browser.version is "6.0"
            scroller_object.css "top", (document.documentElement.scrollTop + 15) + "px"
          else
            scroller_object.css
              top: "40px"
        else if document.documentElement.scrollTop < offset or window.pageYOffset < offset
          scroller_object.css
            position: "absolute"
            top: "0"

  uploadDialog = (options) ->
    if not (options and options.upload_url)
      return
    else
      @options = options

    @$upload_dialog = $("#upload-dialog")
    if @$upload_dialog.length == 0
      $("body").append('<div id="upload-dialog"><div>')
      @$upload_dialog = $("#upload-dialog")
    else
      @$upload_dialog.empty()

    template = _.template($("#upload-dialog-template").html())
    header_message = (if options.header_message then options.header_message else "File upload dialog")
    body_message = (if options.body_message then options.body_message else "")
    disable_weburl = (if options.disable_weburl == true then true else false)

    @$upload_dialog.html template
      header_message: header_message
      body_message: body_message
      disable_weburl: disable_weburl
    @$upload_dialog.find("#fileupload-modal").modal()

    that = @

    #empty the alternate tab
    @$upload_dialog.find("a[data-toggle='tab']").bind "click", (e) ->
      tabSelector = $(e.currentTarget).parent().siblings().find("a").attr("href")
      $(that.$upload_dialog).find(tabSelector).find("input").val("")

    #enter keypress handler for url input box
    @$upload_dialog.find("input.uploadurl").unbind()
    @$upload_dialog.find("input.uploadurl").bind "keypress", (e) ->
      code = if e.keyCode then e.keyCode else e.which
      if code == 13
#Enter keycode
        e.preventDefault()
        that.$upload_dialog.find("a.upload").click()

    @$upload_dialog.find("a.upload").bind("click", (e) ->
      if $(e.currentTarget).hasClass("disabled")
        return

      that.$upload_dialog.find('.errorp').hide()
      that.$upload_dialog.find('.successp').hide()
      $(e.currentTarget).addClass("disabled")
      $(e.currentTarget).button("loading")
      data = (if that.options.data then that.options.data else {})
      $.ajax(that.options.upload_url,
        data: data
        files: $(":file", that.$upload_dialog)
        iframe: true
        processData: true
      ).complete((data) ->
        resp = $.parseJSON(data.responseText)
        $(e.currentTarget).removeClass("disabled")
        $(e.currentTarget).button("reset")
        if resp.status
# close
          if that.options.success_message != undefined
            that.$upload_dialog.find('.successp').html(that.options.success_message)
            that.$upload_dialog.find('.successp').show()
            that.$upload_dialog.find('form').hide()
            $(e.currentTarget).hide()
          else
            that.$upload_dialog.find("#fileupload-modal").modal('hide')
          if that.options.parent_model and that.options.parent_view
            that.options.parent_model.render_once = false
            that.options.parent_model.fetch
              success: ->
                activeTab = that.options.parent_view.activeTab
                if activeTab
                  that.options.parent_view.activeTab = 3
                  that.options.parent_view.render()
                  that.options.parent_view.activeTab = activeTab
                  that.options.parent_view.renderResume(true)

        else
# show error
          that.$upload_dialog.find('.errorp').html(resp.message)
          that.$upload_dialog.find('.errorp').show()
      )
    )

  padZeros = (num, size) ->
    s = "0000000000" + num
    s.substr(s.length - size)

  mp_ping = () ->
    if app.mp_ping_interval != undefined
      app.mp_ping_interval += 2
    else
      app.mp_ping_interval = 0

    app.loggedin or= false

    data =
      interval: app.mp_ping_interval
      loggedin: app.loggedin

    if mpq != undefined and mpq.track != undefined and app.mp_ping_interval % 10 == 0
      mpq.track "Ping", data

  numberSuffix = (number) ->
    if number > 0
      mod10 = number % 10
      if mod10 == 1 and number != 11
        return number + 'st'
      else if mod10 == 2 and number != 12
        return number + 'nd'
      else if mod10 == 3 and number != 13
        return number + 'rd'
      else
        return number + 'th'
    else
      return number

  showLoginError = (prefix) ->
    if _.clone(prefix) != 'phackerprofile' or _.clone(prefix) != 'phackerboard'
      $('body').append('<div style="position: absolute; top: 30%; left: 40%; background-color: #fff; border-radius: 15px; padding: 20px; border: 3px #ccc solid;"><p>You must <a href="user/login">login</a> before you can view this page</p></div>')

  successStatus = () ->
    @$success_status = $("#success-status-wrap")
    if @$success_status.length == 0
      $("body").append('<div id="success-status-wrap"><div>')
      @$success_status = $("#success-status-wrap")
    else
      @$success_status.empty()

    height = 50

    styles =
      "position": "fixed"
      "top": "0px"
      "left": "0px"
      "height": height+"px"
      "text-align": "center"
      "width": "100%"
      "z-index": "9999"
      "background": "#333 url('public/images/success-bar-bg.jpg')"

    that = @
    _.each styles, (v, k) ->
      that.$success_status.css(k, v);

    $('body').addClass('home-status-padding');
    $('body div.navbar.navbar-fixed-top').addClass('navbar-status-padding');

    @$success_status.hide()
    @$success_status.html """
        <div style='width: 960px; margin: 0px auto; position: relative;'>
          <p style='margin-top:10px; font-size: 20px; color: white; padding-top: 3px;'>Congratulations! You have solved this problem!</p>
        </div>
      """
    @$success_status.fadeIn()
    @$success_status.find('a.closeit').die()

    @

  closeSuccessStatus = () ->
    $success_status = $("#success-status-wrap")
    if $success_status.length != 0
      $success_status.fadeOut()
      $('body').removeClass('home-status-padding');
      $('body div.navbar.navbar-fixed-top').removeClass('navbar-status-padding');
      $success_status.html('')

    @

  # To save a object in cookie quickly

  objCookie = (key, val)->

    if( val == undefined )
      try
        val = JSON.parse($.cookie(key))
      catch e
        val = $.cookie(key)
      val

    else
      if( typeof(val) == "object" )
        $.cookie( key, JSON.stringify(val) )
      else
        $.cookie( key, val )


  htmlEncode = (value) ->
    if value is '' or value is undefined
      return ''
    String(value).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

  trackActivity = (event, data={})=>
    if CodePair and Firebase and CodePair.tracker
      CodePair.tracker.trackActivity(event, data)

  track = (event, data = {}, callback = "") ->
    trackActivity(event, data)
    data["slug"] = window.location.pathname.split('/').pop()
    if typeof mixpanel != "undefined"
      if _.isEmpty(callback)
        mixpanel.track event, data
      else
        mixpanel.track event, data, callback
    else
      return

  trackHeap = (event, data = {}) ->
    trackActivity(event, data)
    data["slug"] = window.location.pathname.split('/').pop()
    heap = window.heap
    if not (heap? and heap.track?)
      return
    heap.track event, data


  encrypt = (plain_text, key)->
    if CryptoJS and CryptoJS.TripleDES and CryptoJS.TripleDES.encrypt and plain_text and key
      CryptoJS.TripleDES.encrypt(plain_text, key).toString()
    else
      false

  decrypt = (encrypted_text, key)->
    if CryptoJS and CryptoJS.TripleDES and CryptoJS.TripleDES.decrypt and encrypted_text and key
      CryptoJS.TripleDES.decrypt(encrypted_text, key).toString( CryptoJS.enc.Utf8 )
    else
      false


  IS('util').pagination = pagination
  IS('util').trim = trim
  IS('util').ajaxmsg = ajaxmsg
  IS('util').initializeTimers = initializeTimers
  IS('util').semiFix = semiFix
  IS('util').uploadDialog = uploadDialog
  IS('util').padZeros = padZeros
  IS('util').mp_ping = mp_ping
  IS('util').numberSuffix = numberSuffix
  IS('util').showLoginError = showLoginError
  IS('util').successStatus = successStatus
  IS('util').closeSuccessStatus = closeSuccessStatus
  IS('util').htmlEncode = htmlEncode
  IS('util').objCookie = objCookie
  IS('util').track = track
  IS('util').trackHeap = trackHeap
  IS('util').trackActivity = trackActivity
  IS('util').encrypt = encrypt
  IS('util').decrypt = decrypt


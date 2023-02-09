var videoJsonText = "";
var videoUUIDBTNTag = "201811281416";
var videoBtnMaskWebUrl = "videoBtnMaskWebUrl";
var videoBtnMaskMediaUrl = "videoBtnMaskMediaUrl";
var videoBtnMaskTitle = "videoBtnMaskTitle";
var videoBtnMaskState = "videoBtnMaskState";
var videoMsgRect = "";
!function() {
    var i = !0,
    r = Array(),
    a = null,
    d = !1,
    s = 1;
    function l() {
        try {
            return window.self === window.top
        } catch (e) {
            return !1
        }
    }
    function u(e, t) {
        for (var n = new Array, o = 0; o < e.length; o++) {
            n.push(e[o])
        }
        for (o = 0; o < t.length; o++) {
            n.push(t[o])
        }
        return n
    }
    function f() {
        return u(document.getElementsByTagName("video"), document.getElementsByTagName("audio"))
    }
    window.__firefox__ || (window.__firefox__ = {});
    var e = [];
    e.push(["youjizz.com, ijizz.mobi", function() {
            var e = "",
            t = document.getElementById("preview");
            return null !== t && 0 < (t = t.getElementsByClassName("preview_thumb")).length && (e = t[0].href), e
            }]), e.push(["beeg.com", function() {
                         var e = document.getElementsByClassName("play-video"),
                         t = e.length;
                         if (0 < t) {
                         for (--t; 0 <= t; t--) {
                         var n = e[t].href;
                         if (null != n && 0 < n.length) {
                         return n = e[t].href
                         }
                         }
                         }
                         return null
                         }]), e.push(["hd9.in,hd9.me", function() {
                                      for (var e = document.getElementsByTagName("a"), t = 0; t < e.length; t++) {
                                      var n = e[t].href;
                                      if (11 < n.length && ".mp4" == n.substr(n.length - 4, 4)) {
                                      return n
                                      }
                                      }
                                      }]), e.push(["bokepmi.com", function() {
                                                   for (var e = document.getElementsByTagName("a"), t = 0; t < e.length; t++) {
                                                   var n = e[t].href;
                                                   if (0 < n.length && (0 < n.indexOf(".mp4") || 0 < n.indexOf(".3gp"))) {
                                                   return n
                                                   }
                                                   }
                                                   }]), e.push(["borwap.net", function() {
                                                                for (var e = document.getElementsByTagName("a"), t = 0; t < e.length; t++) {
                                                                if ("nofollow" == e[t].rel) {
                                                                return e[t].href
                                                                }
                                                                }
                                                                }]), e.push(["you--jizz.info,jizzjizz.com,youjizzltd.com,pornsexpages.com,mobileboner.com,porn-mobile.xxx,ludoflash.com,jasonoakley.me,asiantube.xxx,freeporn22.com,xuporn.com,freepronvideos.org,asiaxxxporn.com,flashostar.com,freexvideos.in,fraspi.com,cameltoehoes.com,pron.co,tube4jizz.com,onsexvideos.com,freeprontube.net,footjob101.com,xporntube.us,4tube.tv,youjizz-com.info,allfreevideoporn.com,beeg.co,freepornzeta.com,jizz-on.com,freeporntube.com,twnode6.com,mofoshub.com,ero-video.net", function() {
                                                                             var e = "",
                                                                             t = document.getElementsByClassName("play");
                                                                             null !== t && 0 < t.length && (e = t[0].href);
                                                                             return e
                                                                             }]);
    var c = {};
    function m(e, t) {
        var n = document.createEvent("HTMLEvents");
        n.initEvent(t, !1, !0), n.isTakeEvent = !0, (null != e.originVideo ? e.originVideo : e).dispatchEvent(n)
    }
    function n(e, t, n) {
        i = e, n && (d = !0), r = t && 0 < t.length ? t.split(" ") : Array(), i && w(), o()
    }
    function o() {
        if (l()) {
            for (var e = window.frames, t = 0; t < e.length; t++) {
                e[t].postMessage('{"setVideoEnable":' + i + "}", "*")
            }
        }
    }
    function t() {
        if (0 != i) {
            o(), w();
            var e = document.body.children;
            if (1 == e.length && ("video" == e[0].tagName.toLowerCase() || "audio" == e[0].tagName.toLowerCase())) {
                var t = N(e[0]);
                t && 0 != t.length || (t = window.location.href), k(t, document.title, "get");
                var n = document.body.innerHTML;
                n += '<div id="AlookVideoCover" style="max-width: 100%;position: fixed;left: 0;right: 0;top: 0;bottom: 0; max-height: 100%;width: 100%; height: 100%;">', document.body.innerHTML = n, window.setTimeout(function() {
                                                                                                                                                                                                                         document.getElementById("AlookVideoCover").onclick = function() {
                                                                                                                                                                                                                         k(t, document.title, "play")
                                                                                                                                                                                                                         }
                                                                                                                                                                                                                         }, 50)
            }
        }
    }
    e.forEach(function(t) {
              t[0].split(",").forEach(function(e) {
                                      c[e] = t[1]
                                      })
              }), window.__firefox__ || (window.__firefox__ = {}), l() ? (window.__firefox__.videoStopLoading = t, window.__firefox__.setVideoClick = function() {
                                                                          s = 0;
                                                                          for (var e = window.frames, t = 0; t < e.length; t++) {
                                                                          e[t].postMessage('{"videoClickPlay":1}', "*")
                                                                          }
                                                                          }, window.__firefox__.videoDispatchEnd = function() {
                                                                          if (a) {
                                                                          m(a, "ended")
                                                                          } else {
                                                                          for (var e = window.frames, t = 0; t < e.length; t++) {
                                                                          e[t].postMessage('{"videoDispatchEnd":1}', "*")
                                                                          }
                                                                          }
                                                                          }, window.__firefox__.setMainFrameVideoEnable = n, window.addEventListener("message", function(e) {
                                                                                                                                                     "string" == typeof e.data && -1 != e.data.indexOf("videoFrameReady") && o()
                                                                                                                                                     })) : window.addEventListener("message", function(e) {
                                                                                                                                                                                   if ("string" == typeof e.data) {
                                                                                                                                                                                   if (-1 != e.data.indexOf("setVideoEnable")) {
                                                                                                                                                                                   var t = JSON.parse(e.data);
                                                                                                                                                                                   null != t.setVideoEnable && n(t.setVideoEnable)
                                                                                                                                                                                   } else {
                                                                                                                                                                                   -1 != e.data.indexOf("videoDispatchEnd") ? a && m(a, "ended") : -1 != e.data.indexOf("videoClickPlay") && (s = 0)
                                                                                                                                                                                   }
                                                                                                                                                                                   }
                                                                                                                                                                                   }), document.addEventListener("DOMContentLoaded", function() {
                                                                                                                                                                                                                 l() ? (o(), w()) : window.parent.postMessage('{"videoFrameReady":1}', "*"), p()
                                                                                                                                                                                                                 }), window.addEventListener("load", t), window.addEventListener("popstate", function(e) {
                                                                                                                                                                                                                                                                                 v("popstate"), e.state && (p(), w())
                                                                                                                                                                                                                                                                                 });
    var g = window.history.pushState;
    window.history.pushState = function(e, t, n) {
        v("pushState"), g.apply(window.history, arguments), p(), w()
    };
    var h = window.history.replaceState;
    function p() {
        s = 1
    }
    function v(e) {
        webkit.messageHandlers.VideoHandler.postMessage(e)
    }
    function w() {
        if (0 != i) {
            L(), document.removeEventListener("DOMNodeInserted", A, !1), document.addEventListener("DOMNodeInserted", A, !1), d || (HTMLVideoElement.prototype.play = y, HTMLVideoElement.prototype.load = E, HTMLAudioElement.prototype.play = y, HTMLAudioElement.prototype.load = E);
            var e = function() {
                var e = window.location.hostname,
                t = c[e];
                if (!t) {
                    for (var n in c) {
                        -1 !== e.indexOf(n, e.length - n.length) && (t = c[n])
                    }
                }
                if (t) {
                    return t()
                }
            }(),
            t = !1,
            n = f();
            if (n) {
                for (var o = 0; o < n.length; o++) {
                    N(n[o])
                }
            }
            if (n) {
                for (var o = 0; o < n.length; o++) {
                    V(n[o]), e && 0 != e.length || (e = N(n[o])), t = !0
                }
            }
            !t || e && 0 != e.length || window.setTimeout(function() {
                                                          var e = f();
                                                          if (e) {
                                                          for (var t = 0; t < e.length && !_(e[t], "get"); t++) {}
                                                          }
                                                          }, 180), k(e, document.title, "get")
        }
    }
    function y() {
        !this.originVideo && this.parentNode && function(e) {
            var t = e.parentNode;
            if (t) {
                var n = e.cloneNode(!0);
                n.onclick = function(e) {
                    e && e.target && (("VIDEO" == (e = e.target).nodeName || "AUDIO" == e.nodeName) && e.play())
                }, n.takeListened = !0, n.originVideo = e, function(e) {
                    e.removeAttribute("src");
                    for (var t = e.getElementsByTagName("source"), n = 0; n < t.length; n++) {
                        t[n].removeAttribute("src")
                    }
                }(n), V(n), t.replaceChild(n, e)
            }
        }(this);
        var e = window.event;
        if (!e || "click" != e.type && "tap" != e.type && 0 != e.type.indexOf("touch") || (s = 0), -1 == window.location.hostname.indexOf("youku.com") || 1 != s) {
            var t = _(null != this.originVideo ? this.originVideo : this, "play");
            if (a = this, window.setTimeout(function() {
                                            m(this, "play")
                                            }, 100), t && 0 < r.length) {
                for (var n = !1, o = 0; o < r.length; o++) {
                    if (-1 != t.src.indexOf(r[o])) {
                        n = !0;
                        break
                    }
                }
                n && m(this, "ended")
            }
        }
    }
    function E() {
        "audio" == this.tagName.toLowerCase() ? (s = 0, _(this, "play")) : _(this, "get")
    }
    function b(e) {
        if (!e.isTakeEvent && i) {
            s = 0;
            var n = e.target,
            o = _(null != n.originVideo ? n.originVideo : n, "play");
            (a = n).takePlayURL = o.src, window.setTimeout(function() {
                                                           if (n.pause(), o && 0 < r.length) {
                                                           for (var e = !1, t = 0; t < r.length; t++) {
                                                           if (-1 != o.src.indexOf(r[t])) {
                                                           e = !0;
                                                           break
                                                           }
                                                           }
                                                           e && m(n, "ended")
                                                           }
                                                           }, 100)
        }
    }
    function x(e) {
        e.stopImmediatePropagation()
    }
    function _(e, t) {
        return k(N(e), function(e) {
                 var t = e.getAttribute("title");
                 if (!t || 0 == t.length) {
                 var n = document.querySelector(".x-video-title");
                 n && (t = n.innerText)
                 }
                 t && 0 != t.length || (t = document.title);
                 return t || ""
                 }(e), t)
    }
    function k(e, t, n) {
        if (!e || 0 == e.length) {
            return null
        }
        var o = {
        src: e,
        title: t,
        isMainFrame: l(),
        referer: location.href,
        autoPlay: s,
        msgId: n
        };
        
        window.postMessage('{"willMaskVideoBtn":' + videoMsgRect + "}", "*")
        return webkit.messageHandlers.VideoHandler.postMessage(o), o
    }
    function N(e) {
        var t = e.src;
        videoMsgRect = ""
        if (t && 0 < t.length) {
            t = e.src
            {
                var rc = e.getBoundingClientRect();
                videoMsgRect = rc.top+":"+rc.right+":"+rc.left+":"+rc.bottom+":"+rc.width+":"+rc.height;
            }
        } else {
            for (var n = "", o = e.getElementsByTagName("source"), i = 0; i < o.length; ++i) {
                var r = o[i],
                a = r.getAttribute("src"),
                d = r.getAttribute("type");
                if (a && 0 < a.length) {
                    var s = r.src;
                    if (s && 0 < s.length) {
                        var l = e.canPlayType(d);
                        if ("probably" == l) {
                            t = r.src;
                            break
                        }
                        "maybe" == l ? t = r.src : n = r.src
                    }
                }
            }
            (!t || t.length <= 0) && 0 < n.length && (t = n)
        }
        return t || ""
    }
    function addmask2(e, q, t, m) {
        if (q == null) {
            return
        }
        var videoSrc = e.src;
        if (m && m.length > 2) {
            videoSrc = m
        }
        var rc = q.getBoundingClientRect();
        var body = document.body;
        var btn = document.createElement("input");
        btn.type = "button";
        btn.name = t;
        btn.value = "";
        btn.setAttribute(videoBtnMaskWebUrl, document.URL);
        btn.setAttribute(videoBtnMaskTitle, document.title);
        btn.setAttribute(videoBtnMaskState, "play");
        btn.setAttribute(videoBtnMaskMediaUrl, videoSrc);
        btn.style.opacity = "0.0";
        btn.style.top = rc.top + "px";
        btn.style.backgroundColor = "transparent";
        btn.style.right = rc.right + "px";
        btn.style.left = rc.left + "px";
        btn.style.bottom = rc.bottom + "px";
        btn.style.width = rc.width + "px";
        btn.style.height = rc.height + "px";
        btn.style.position = "absolute";
        btn.style.zIndex = 2147483647;
        body.parentNode.appendChild(btn);
        btn.addEventListener("click", function(e) {
                             var o = {
                             webUrl: e.target.getAttribute(videoBtnMaskWebUrl),
                             title: e.target.getAttribute(videoBtnMaskTitle),
                             state: e.target.getAttribute(videoBtnMaskState),
                             referer: location.href,
                             videoUrl: e.target.getAttribute(videoBtnMaskMediaUrl),
                             x: e.target.getBoundingClientRect().x,
                             y: e.target.getBoundingClientRect().y,
                             w: rc.width,
                             h: rc.height
                             };
                             return webkit.messageHandlers.ClickOverButttonVideo.postMessage(o)
                             })
    }
    function isSpecialDom() {
        var r = false;
        var obj = videoJsonText["pecial"];
        var domain = document.domain;
        var findmask = null;
        for (var keyValue in obj) {
            if (domain.indexOf(keyValue) != -1) {
                r = true;
                break
            }
        }
        return r
    }
    function findMaskParent() {
        var obj = videoJsonText;
        var domain = document.domain;
        var findmask = null;
        for (var keyValue in obj) {
            if (domain.indexOf(keyValue) != -1) {
                var o = obj[keyValue];
                for (var i = 0; i < o.length; i++) {
                    findmask = document.getElementById(o[i]);
                    if (findmask != null) {
                        break
                    }
                }
                break
            }
        }
        return findmask
    }
    function addmask(e, t) {
        var uuidBtn = encodeURIComponent(t);
        var rc = e.getBoundingClientRect();
        var findValue = document.getElementsByName(uuidBtn);
        if (findValue.length != 0) {
            return
        }
        if ((rc.width + rc.height < 20)) {
            if (videoJsonText.constructor != Object) {
                return
            }
            var findmask = findMaskParent();
            addmask2(e, findmask, uuidBtn, t)
        } else {
            addmask2(e, e, uuidBtn, t)
        }
    }
    function A(e) {
        var t,
        n = e.target;
        if ("VIDEO" == n.nodeName || "AUDIO" == n.nodeName) {
            t = n
        } else {
            if (0 < n.childElementCount) {
                var o = u(n.getElementsByTagName("video"), n.getElementsByTagName("audio"));
                0 < o.length && (t = o[0])
            }
        }
        if (t && L(), t && !t.takeListened) {
            var i = (t.contentWindow ? t.contentWindow : window).HTMLVideoElement.prototype;
            d || i.play === y || (i.play = y, i.load = E), V(t), _(t, "get") || window.setTimeout(function() {
                                                                                                  _(t, "get")
                                                                                                  }, 180)
        }
    }
    function L() {
        var e = f();
        if (0 != e.length && !0 !== e[0].takeAddSrcChange) {
            var t = e[0];
            new MutationObserver(function(e) {
                                 e.forEach(function(e) {
                                           "src" === e.attributeName && _(t, "get")
                                           })
                                 }).observe(t, {
                                            attributes: !0,
                                            attributesFilter: ["src"]
                                            }), t.takeAddSrcChange = !0
        }
    }
    function T(e, t, n) {
        e.takeEventArray || (e.takeEventArray = new Array), -1 == e.takeEventArray.indexOf(t) && (e.addEventListener(t, n, !1), e.takeEventArray.push(t))
    }
    function V(e) {
        d || (e.play = y, e.load = E), T(e, "play", b), T(e, "pause", x), e.webkitEnterFullscreen = function(e) {}, e.webkitEnterFullScreen = function(e) {}, e.webkitRequestFullScreen = function(e) {}, e.webkitRequestFullscreen = function(e) {}, e.removeAttribute("autoplay"), e.setAttribute("preload", "none"), e.setAttribute("webkit-playsinline", ""), e.setAttribute("playsinline", ""), e.tagName && "audio" != e.tagName.toLowerCase() && (e.controls = 1)
    }
    window.history.replaceState = function(e, t, n) {
        v("replaceState"), h.apply(window.history, arguments)
    }
}();


var updatelistTime = -1;
var AdBlockupdateTime = -1;
var videoUrl = null;
var timeVar = 0;
var timeDelayVar = 0;
var timeApiDelay = 0;
var iqyiTimeVar = 0;
var currenthtmlUrl = null;
var qqhostS = {"url":"m.v.qq.com","seek":false};
var qqhost = new Array("/x/", "/cover/", "/page/", "cid=");
var qqApi = new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var funtvhost=new Array("/mplay/");
var funtvhostS = {"url":"fun.tv","seek":false};
var funtvApi = new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var mghost=new Array("/b/","/cover/", "/page/", "/l/");
var mghostS = {"url":"m.mgtv.com","seek":false};
var mgApi =  new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var ykhost=new Array("id=","id_");
var ykhostS = {"url":"m.youku.com","seek":false};
var ykApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var iqyhost=new Array("id_","v_");
var iqyhostS = {"url":"m.iqiyi.com","seek":false};
var iqyApi = new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var tvsohuhost=new Array("aid=","channeled");
var tvsohuhostS = {"url":"m.tv.sohu.com","seek":false};
var tvsohuApi = new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var sohuhost=new Array("aid=","channeled");
var sohuhostS = {"url":"m.sohu.com","seek":false};
var sohuApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");


var bilihost=new Array("play");
var bilihostS = {"url":"m.bilibili.com","seek":false};
var biliApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");


var pptvhost=new Array("show");
var pptvhostS = {"url":"m.pptv.com","seek":false};
var pptvApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");


var v1905host=new Array("play");
var v1905hostS = {"url":"1905.com","seek":false};
var v1905Api =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");


var baofenghost=new Array("play");
var baofenghostS = {"url":"m.baofeng.com","seek":false};
var baofengApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var fengxinghost=new Array("mplay");
var fengxinghostS = {"url":"m.fun.tv","seek":false};
var fengxingApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");

var miguhost=new Array("detail");
var miguhostS = {"url":"m.miguvideo.com","seek":false};
var miguApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");


var lehost=new Array("vplay_");
var lehostS = {"url":"m.le.com","seel":false};
var leApi =new Array("http://jx.mw0.cc/?url=","https://api.8bjx.cn/?url=","http://jiexi.071811.cc/jx.php?url=","http://5.nmgbq.com/2/?url=","https://cs2.ejiafarm.com/dy.php?url=","https://api.sigujx.com/?url=","http://jsap.attakids.com/?url=");



var currentApi = null;
var apiSeek = false;

function removeAllTime(){
    if(timeVar!=0){
        clearInterval(timeVar);
        timeVar = 0;
    }
    if(timeDelayVar!=0){
        clearInterval(timeDelayVar);
        timeDelayVar = 0;
    }
    if(timeApiDelay!=0){
        clearInterval(timeApiDelay);
        timeApiDelay = 0;
    }
}

function loadedMetaDataHandler() {
    var metaData = player.getMetaDate();
    var html = '';
    if(parseInt(metaData['videoWidth']) > 0) {
        var time = metaData['duration'];
        if(time!=null && time>1){
            window.webkit.messageHandlers.GetInfoTime.postMessage(time>660?"0":"1");
            removeAllTime();
        }
    } else {
    }
}

function delayPlay(){
    removeAllTime();
    window.webkit.messageHandlers.GetInfoTime.postMessage("1");
}


function delayCilck() {
    var realbb = window.location.href;
    if (realbb.indexOf('youku.com') != -1 && ((realbb.indexOf('alipay_video') != -1)||(( realbb.indexOf('video/id') != -1)&&( realbb.indexOf('video/id_X') == -1)))) {
        var classArray = new Array();
        classArray.push('waist active');
        classArray.push('select active');
        for (i = 0; i < classArray.length; i++) {
            var list = document.getElementsByClassName(classArray[i]);
            if (list != null && list.length > 0) { //调用click 事件
                list[0].parentNode.click();
                break;
            }
        }
    }
    addVipBts();
}

;


function qrCheckVaild(){
    return currentApi!=null?false:true;
};

function externParam(url){
    var playScript = document.getElementById('play_video_script');
    if(playScript==null){
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.id  ="play_video_script";
        var fext = "var videoObject ={"
        fext+="container: '.video',";
        fext+="variable: 'player',";
        fext+="autoplay:false,";
        fext+="seek:1,";
        fext+="mobileAutoFull:false,";
        fext+="video:'";
        fext+=url;
        fext+="'";
        fext+="};";
        fext+="var player=new ckplayer(videoObject);";
        script.appendChild(document.createTextNode(fext));
        document.body.appendChild(script);
        timeVar = window.setInterval(function() {
                                     loadedMetaDataHandler();
                                     }, 1000);
        timeDelayVar = window.setInterval(function() {
                                          delayPlay();
                                          }, 5000);
    }
}

function checkVaild(url,host){
    var rules = null;
    currentApi= null;
    if(qqhostS["url"].indexOf(host)!=-1){
        rules = qqhost;
        currentApi = qqApi;
        apiSeek = qqhostS["seek"];
   // window.setTimeout(qq_play, 1000 * 2);
    }
    else if(funtvhostS["url"].indexOf(host)!=-1){
        rules = funtvhost;
        currentApi = funtvApi;
        apiSeek = funtvhostS["seek"];
    }
    else if(mghostS["url"].indexOf(host)!=-1){
        rules = mghost;
        currentApi = mgApi;
        apiSeek = mghostS["seek"];
    }
    else if(ykhostS["url"].indexOf(host)!=-1){
        rules = ykhost;
        currentApi = ykApi;
        apiSeek = ykhostS["seek"];
    // window.setTimeout(youku_play, 1000 * 3);
    }
    else if(iqyhostS["url"].indexOf(host)!=-1){
        rules = iqyhost;
        apiSeek = iqyhostS["seek"];
        currentApi = iqyApi;
    }
    else if(tvsohuhostS["url"].indexOf(host)!=-1){
        rules = tvsohuhost;
        apiSeek = tvsohuhostS["seek"];
        currentApi = tvsohuApi;
    }
    else if(sohuhostS["url"].indexOf(host)!=-1){
        rules = sohuhost;
        apiSeek = sohuhostS["seek"];
        currentApi = sohuApi;
    }
    else if(pptvhostS["url"].indexOf(host)!=-1){
        rules = pptvhost;
        apiSeek = pptvhostS["seek"];
        currentApi = pptvApi;
    }
    else if(bilihostS["url"].indexOf(host)!=-1){
        rules = bilihost;
        apiSeek = bilihostS["seek"];
        currentApi = biliApi;
    }
     else if(v1905hostS["url"].indexOf(host)!=-1){
        rules = v1905host;
        apiSeek = v1905hostS["seek"];
        currentApi = v1905Api;
    }
     else if(fengxinghostS["url"].indexOf(host)!=-1){
        rules = fengxinghost;
        apiSeek = fengxinghostS["seek"];
        currentApi = fengxingApi;
    }
      else if(miguhostS["url"].indexOf(host)!=-1){
        rules = miguhost;
        apiSeek = miguhostS["seek"];
        currentApi = miguApi;
    }
       else if(baofenghostS["url"].indexOf(host)!=-1){
        rules = baofenghost;
        apiSeek = baofenghostS["seek"];
        currentApi = baofengApi;
    }
    else if(lehostS["url"].indexOf(host)!=-1){
        rules = lehost;
        apiSeek = lehostS["seek"];
        currentApi = leApi;
    }
    var returnValue = false;
    if(rules!=null){
        for(var i = 0;i<rules.length;i++){
            if( url.indexOf(rules[i])!=-1){
                returnValue = true;
                break;
            }
        }
    }
    return returnValue;
}

function addVipBts(){
    var divda = document.getElementById('vip_btnsv');
    if (divda == null) {
        var divceshia = document.createElement('div');
        divceshia.setAttribute('style', 'z-index: 9999; position: fixed ! important; left: 0px; bottom: 0px;');
        document.body.append(divceshia);
        divceshia.id = "vip_btnsv";
        var head = divceshia;
       head.innerHTML='<img id=vip_btns_imagea src="https://pyqapp.oss-cn-hangzhou.aliyuncs.com/play_pyq.png" height="60px" width="100%" />';
        var object = document.getElementById('vip_btns_imagea');
        object.setAttribute('onclick',"playWebs();");
        postGetAssetSuccessMsg();
        debugger;
        var webUrl = document.documentURI;
        if (webUrl.indexOf("iqiyi.com")!=-1 || webUrl.indexOf("m.v.qq.com")!=-1 ||
             webUrl.indexOf("m.le.com")!=-1 ||
            webUrl.indexOf("m.tv.sohu.com")!=-1){
             currenthtmlUrl = webUrl;
            iqiyiFix();
        }
    }
}


function postGetAssetSuccessMsg(){
    if(currentApi!=null){
           var apis = new Array();
           var webUrl = document.documentURI;
           for(var i = 0;i<currentApi.length;i++){
               apis.push(currentApi[i]+webUrl);
           }
           window.webkit.messageHandlers.GetAssetSuccess.postMessage({"array":apis,"seek":apiSeek});
    }
}


function youku_play(){
    var playbox = document.getElementById('playerBox');
    playbox.style.height = "0px";

  var divda = document.getElementById('vip_btns');
    if (divda == null) {
        var divceshia = document.createElement('div');
       
         playbox.append(divceshia);
        divceshia.id = "vip_btns";
        var head = divceshia;
        head.innerHTML='<img id=vip_btns_image src="https://pyqapp.oss-cn-hangzhou.aliyuncs.com/p.png"  mix-width="414px" width="100%" />';
        var object = document.getElementById('vip_btns_image');
        object.setAttribute('onclick',"playWebs();");}

}


function qq_play(){
    var playbox = document.getElementById('vip_header');
    

  var divda = document.getElementById('vip_btns');
    if (divda == null) {
        var divceshia = document.createElement('div');
       
         playbox.append(divceshia);
        divceshia.id = "vip_btns";
        var head = divceshia;
        head.innerHTML='<img id=vip_btns_image src="https://pyqapp.oss-cn-hangzhou.aliyuncs.com/p.png" height="100%" width="100%" />';
        var object = document.getElementById('vip_btns_image');
        object.setAttribute('onclick',"playWebs();");}

}





function homebtn(){
    var divdb = document.getElementById('vip_btnsb');
    if (divdb == null) {
        var divceshib = document.createElement('div');
        divceshib.setAttribute('style', 'z-index: 99991; position: fixed ! important; left: 0px; bottom: 40px;');
        document.body.append(divceshib);
        divceshib.id = "vip_btnsb";
        var head = divceshib;
        head.innerHTML='<a href="https://pyqapp.oss-cn-hangzhou.aliyuncs.com/max.html"> <img src="https://pyqapp.oss-cn-hangzhou.aliyuncs.com/home_btn.png" height="50px" width="50px" /></a>';
        
    }
}

function iqiyiFix(){
    if(iqyiTimeVar==0){
              iqyiTimeVar = window.setInterval(function() {
                  if(document.documentURI=="https://m.iqiyi.com/" || document.documentURI=="http://m.le.com/" ||
                     document.documentURI=="https://m.tv.sohu.com/")return;
                  if(currenthtmlUrl==document.documentURI){
                  }
                  else{
                      currenthtmlUrl = document.documentURI;
                     postGetAssetSuccessMsg();
                  }
              }, 1000);
          }
}

function qrTryDoIt()
{
  var webUrl = document.documentURI;
    if (webUrl.indexOf("iqiyi.com")!=-1 ||
        webUrl.indexOf("m.le.com") !=-1 ||
        webUrl.indexOf("m.v.qq.com")!=-1||
        webUrl.indexOf("m.tv.sohu.com")!=-1){
        postGetAssetSuccessMsg();
        currenthtmlUrl = webUrl;
        iqiyiFix();
        return;
    }
    if(iqyiTimeVar!=0){
        clearInterval(iqyiTimeVar);
        iqyiTimeVar = 0;
    }
  return playWebs();
}

function changeTxUrlVid(x){
    var ret = x;
    if (x.indexOf(".html?vid=")!=-1){
       ret = x.replace(".html?vid=","/") + ".html";
    }
    return ret;
}

function  checkUrlVaild(){
    var webUrl = document.documentURI;
    if(webUrl.indexOf("m.fun.tv/mplay/")!=-1 && webUrl.indexOf("?mid=")!=-1){
       webUrl = webUrl.replace("m.fun.tv/mplay/","www.fun.tv/vplay/");
        webUrl = webUrl.replace("?mid=","g-");
        if(webUrl.indexOf("&vid=")!=-1){
            webUrl = webUrl.replace("&vid=",".v-");
        }
        webUrl+="/";
        return webUrl;
    }
    else{
        return null;
    }
        if (currentApi == qqApi){//qq需要替换
                var qq = "m.v.qq.com";
                webUrl = changeTxUrlVid(webUrl.replace(qq,"v.qq.com"));
        }
    return     webUrl;
}

function playWebs(){
    if(currentApi!=null){
        var apis = new Array();
        var webUrl = document.documentURI;
        for(var i = 0;i<currentApi.length;i++){
            apis.push(currentApi[i]+webUrl);
        }
        window.webkit.messageHandlers.PostMoreInfo.postMessage({"array":apis,"seek":apiSeek});
        return true;
    }
    else
    {
        console.log("playWebs api=null = %s",document.documentURI);
    }
    return false;
}

function qrHanderUrl(url,host){//根据url，组合api返回给客户端，
    // homebtn();
    var b = checkVaild(url,host);
    if(b){
        window.setTimeout(delayCilck, 1000 * 0.1);
        console.log("url yes = %s",url);
    }
    else{
        console.log("url not = %s",url);
    }
    testJump(url);
};

function testJump(url){
    if (url.indexOf('5tuu.com/view/') != -1) {
        url =  url.replace('view/','play/');
        var pos = url.lastIndexOf('.');
        if(pos!=-1){
            url = url.substring(0,pos);
            url+="-0-0.html";
            window.location.href = url;
        }
    }
    
}

function parseApiFaild(){
    removeAllTime();
    window.webkit.messageHandlers.GetInfoTime.postMessage("2");
}

function qrCheckTimeOut(){
    removeAllTime();
    timeDelayVar = window.setInterval(function() {
                                      parseApiFaild();
                                      }, 10000);
}

//
//!function breakDebugger(){
//    if(checkDebugger()){
//        breakDebugger();
//    }
//}();
//
//;function checkDebugger(){
//    const d=new Date();
//    debugger;
//    const dur=Date.now()-d;
//    if(dur<5){
//        return false;
//    }else{
//        return true;
//    }
//}
//
//





var isSet = false;

function updateList(){
    var realbb = window.location.href;
    var videoTitle   = document.title.replace(/[ /d]/g, '');//查找《》里面的数据，并删除数字;
    var startPos = videoTitle.indexOf('《');
    var endPos = videoTitle.indexOf('》');
    if (startPos != -1 && endPos != -1) {
        videoTitle = videoTitle.substring(startPos + 1, endPos);
    }
    var urlArray = new Array();
    var select = 0;
    if (realbb.indexOf('m.iqiyi.com') != -1) { //爱奇艺
        var list = document.getElementsByClassName('juji-list  clearfix');
        if (list.length == 0) {
            list = document.getElementsByClassName('m-album-num clearfix item');
        }
        if (list.length == 0) {
            list = document.getElementsByClassName('m-album-num clearfix');
        }
        if (list.length > 0) {
            var i;
            var jujilist;
            for (i = 0; i < list.length; i++) {
                jujilist = list[i].getElementsByTagName('a');
            }
            
            for (i = 0; i < jujilist.length; i++) {
                var retValue = {
                    'url': 'http:' + jujilist[i].getAttribute('href'),
                    'title': jujilist[i].getAttribute('curpage-index')
                };
                urlArray.push(retValue);
            }
            if (urlArray.length > 0) {
                var dic = {
                    'listArray': urlArray,
                    'ShowName': videoTitle,
                    'SelectIndex': select
                };
                window.webkit.messageHandlers.PostListInfo.postMessage(dic);
            }
        } else {
            var dic = {
                'listArray': urlArray,
                'ShowName': videoTitle,
                'SelectIndex': select
            };
            window.webkit.messageHandlers.PostListInfo.postMessage(dic);
        }
    }
};

function stopCheckList() {
    clearInterval(updatelistTime);
    updatelistTime = -1;
};

function startCheckList() {
    if (updatelistTime == -1) {
        updatelistTime = setInterval(updateList, 1000);
    }
}





function getVideoListArray(domPath ,isVertical){
    var realbb = window.location.href;
    var retArray = new Array();
    
    var result = document.evaluate(domPath, document, null, XPathResult.ANY_TYPE, null);
    var nodes = result.iterateNext(); //枚举第一个元素
    while (nodes) {
        // 对 nodes 执行操作;
        var url = nodes.href;
        var imgUrl = '';
        var title = '';
        var img = nodes.getElementsByTagName('img');
        if (img != null) {
            imgUrl = img[0].getAttribute('src');
        }
        
        var titleNode = nodes.getElementsByClassName('title');
        if (titleNode != null) {
            title = titleNode[0].textContent;
        }
        
        if (imgUrl.length > 2) {
            var dic = {
                'imgUrl': 'http:' + imgUrl,
                'url': url,
                'referer': realbb,
                'isVertical':isVertical,
                'title':title
            };
            retArray.push(dic);
        }
        nodes = result.iterateNext(); //枚举下一个元素
    }
    return retArray;
}

function postFuYaAsset(isClose){
    var retArray = getVideoListArray('/html/body/div[2]/div/div/div[1]/div//a',false);
    window.webkit.messageHandlers.PostAssetInfo.postMessage({"array":retArray,"isClose":isClose});
    $("html, body").animate({
                            scrollTop: $('html, body').get(0).scrollHeight}, 1000);
}

function gotoParseWeb() {
    //虎牙某个路径下的所有a标签
    var realbb = window.location.href;
    if (realbb.indexOf('huya.com') != -1) {
        setTimeout(function(){ postFuYaAsset(false);},100);
        setTimeout(function(){ postFuYaAsset(false);},6000);
        setTimeout(function(){ postFuYaAsset(true);},10000);
    }
    //end
};


!function startCheckAdBlock() {
    if (AdBlockupdateTime == -1) {
        AdBlockupdateTime = setInterval(updateAdBlock, 0.25);
    }
}();

function removeBlocks(){
   var nodes = document.getElementsByTagName('*'); 
   for(var i = 0;i<nodes.length;i++){
      var node = nodes[i];
      var q = node.getAttribute("class");
      var b = node.getAttribute("classname");
      if(node.getAttributeNames().length==3 && q!=null&&b!=null&&q==b){
            node.setAttribute("hidden", true);
                        node.style = "display:none;"
      }
   }
};

function removeFromeStyle(x){
    var v = document.querySelectorAll(x);
    if(v!=null && v.length>0){v[0].setAttribute("hidden",true);}
}

function updateAdBlock() {
	//return;
	removeBlocks();
    var realbb = window.location.href;
     if (realbb.indexOf('huya.com') != -1) {
         return;
         }
	 if (realbb.indexOf('yueyuwu.com') != -1) {
         return;
         }
	  if (realbb.indexOf('qq.com') != -1) {
         return;
         }
     if (realbb.indexOf('baidu.com') != -1) {
         return;
         }
    if (realbb.indexOf('m.tv.sohu.com') != -1) {
         return;
         }
    
    if (realbb.indexOf('m.youku.com') != -1) {
        

    if( document.querySelector(".tv-slide>div") != null){
             document.querySelector(".tv-slide>div").style.width = "400px";
        };


    if( document.querySelector("#Bigdrama") != null){
            document.querySelector("#Bigdrama").remove();
        };

    if( document.querySelector("#banner") != null){
            document.querySelector("#banner").remove();
        };
    if(  document.querySelector("div>ul.hot-row-bottom") != null){
             document.querySelector("div>ul.hot-row-bottom").remove();
        };
     if( document.querySelector("#YKComment") != null){
            document.querySelector("#YKComment").remove();
        };


    
         
         }

         if (realbb.indexOf('iqiyi.com') != -1) {
         $(".m-sliding-list").css("white-space", "pre-wrap");
         $("[name='m-extendBar']").remove();
         $(".m-videoUser-spacing").remove();
         $(".m-iqylink-guide").remove();
         $("[name='m-aroundVideo']").remove();
         $("[name='m-videoRec']").remove();
         $(".m-pp-entrance").remove();
         $("#comment").remove();
         $(".m-iqyDown").remove();
         $("[name='m-movieRec']").remove();
          $("[name='movieHot']").remove();
           $("[name='m-vipWatch']").remove();
           $("[name='m-vipRights']").remove();
         }

         if (realbb.indexOf('m.v.qq.com') != -1) {
            $("#vip_prevue").remove();
            $("#vip_movie_clips").remove();
            $("#vip_privilege").remove();
            $("#vip_activity").remove();
            $("#2016_comment").remove();
            $("#vip_recommendation").remove();
             $(".mod_promotion").remove();
            $("#2016_source_first").remove();
            $("#vip_player").remove();
         }

        
    //所有网站相同规则屏蔽广告pingbi
    if(realbb.indexOf('.com') != -1 ||realbb.indexOf('.cc') != -1 ||realbb.indexOf('.net') != -1  ||realbb.indexOf('.xyz') != -1 ||realbb.indexOf('.tv') != -1 ||realbb.indexOf('.top') != -1 ||realbb.indexOf('.me') != -1 ||realbb.indexOf('.info') != -1 ||realbb.indexOf('.pw') != -1) {





        
        if( document.querySelector("brde") != null){
             document.querySelector("brde").style.zoom = 0.01;
        };
        
        
        
        
        
        removeFromeStyle("[style='position: fixed; z-index: 2147483646; left: 0px; width: 100%; text-align: center; bottom: -5px;']");
        removeFromeStyle("[style='position: fixed; bottom: 0px; width: 100%; z-index: 2147483647; height: auto; animation: gyqdtgo 1s both;']");
        removeFromeStyle("[style='position: fixed; z-index: 9999999999;']");
        removeFromeStyle("[style='position: fixed; z-index: 2147483646; left: 0px; width: 100%; text-align: center; bottom: -5px;']");
        removeFromeStyle("[style='position: text-align:center;margin-top:5px;margin-bottom:0px;']");
        
        
        
        
        
        
        
       // if (realbb.indexOf('m.youku.com') == -1 && realbb.indexOf('.411c.com') == -1 ) {
       // $('div').each(function(index, el) { //删除很多小方块单行
       //               var name = el.className;
       //               var id_name = el.id;
       //               if (id_name !=undefined && name!=undefined) {
       //               var pos= name.lastIndexOf("_");
       //               if (pos!=-1 && id_name.lastIndexOf(name.substring(0,pos))!=-1 && (name != id_name) && el.getAttributeNames().length>=3 ){
       //               el.setAttribute("hidden",true);
       //               el.style = "display:none;"
       //               
       //               }
        //              }
       //               });
		    
	//  $('div').each(function(index, el) { //删除很多小方块单行
         //             var name = el.class;
        //              var id_name = el.id;
        //              if (id_name !=undefined && name!=undefined) {
       //               var pos= name.lastIndexOf("_");
          //            if (pos!=-1 && id_name.lastIndexOf(name.substring(0,pos))!=-1 && (name != id_name) && el.getAttributeNames().length>=3 ){
            //          el.setAttribute("hidden",true);
              //        el.style = "display:none;"
                //      
                  //    }
                    //  }
   //                   });
        
        
     //   $('div').each(function(index, el) {
       //               var name = el.className;
         //             var id_name = el.id;
           //           if (id_name !=undefined && name!=undefined && id_name.length > 0 && name.length > 0 && (name == id_name) &&  (id_name.lastIndexOf("play")==-1 &&  id_name.lastIndexOf("video")==-1 )  ) {
             //         el.setAttribute("hidden",true);
               //       el.style = "display:none;"
                 //     
                   //   }
                     // });
              //}
        
        
    };
    
    
    
    
    
    if (realbb.indexOf('proxyunblock.site') != -1) {
        if (realbb.indexOf('Unblock.php?q=') == -1) {
            var delNode = document.getElementsByTagName('nav');
            if (delNode && delNode.length > 0) {
                delNode[0].remove();
            }
            
            delNode = document.getElementsByTagName('footer');
            
            if (delNode && delNode.length > 0) {
                delNode[0].remove();
            }
            document.body.style.backgroundColor = "black"
            
            delNode = document.getElementById("inputLarge");
            
            if (delNode) {
                delNode.value = "www.google.com";
            }
            
            var remNode = document.getElementsByClassName('container');
            for (var i = 0; i < remNode.length; i++) {
                var delNode = remNode[i];
                var value = delNode.getAttribute('data-sr-id');
                if (value != null && value != '1') {
                    delNode.parentNode.removeChild(delNode);
                }
            }
            
            delAllElementsByCallName('middle');
            delAllElementsByCallName('lead');
            delAllElementsByCallName('container-fluid padding ');
            delAllElementsByTagName_idname('div', 'chitika');
            delAllElementsByTagName_idname('div', 'ntv_');
        } else {
            
        }
    } else if (realbb.indexOf('5tuu.com') != -1) { //
        $("[style='position: fixed; z-index: 2147483646; left: 0px; width: 100%; text-align: center; bottom: -5px;']").remove();
        $(".notes").remove();
        $("[style='clear:both;padding:0px;margin:0px']").remove();
        $('body>div').each(function(index, el) {
                           var name = el.className;
                           var id_name = el.id;
                           if (id_name.length > 0 && name.length > 0 && (name == id_name)) {
                           el.style.zoom = 0.001;
                           return false;
                           }
                           });
        $('[style]').each(function(index, el) {
                          var isFind = false;
                          if (el.attributes.length > 0) {
                          var textValue = el.attributes[0].textContent;
                          if (textValue.length > 1) {
                          textValue = textValue.substring(1, textValue.length);
                          if (!isNaN(textValue)) {
                          isFind = true;
                          }
                          }
                          }
                          
                          if (isFind) {
                          el.remove();
                          return false;
                          }
                          });
        
        function getNow(s) {
            
            return s < 10 ? '0' + s: s;
        }
        
        var myDate = new Date();
        //获取当前年
        var year = myDate.getFullYear();
        //获取当前月
        var month = myDate.getMonth() + 1;
        //获取当前日
        var date = myDate.getDate();
        var h = myDate.getHours(); //获取当前小时数(0-23)
        var m = myDate.getMinutes(); //获取当前分钟数(0-59)
        var s = myDate.getSeconds();
        var b = 0;
        var now = year + '-' + getNow(month) + "-" + getNow(date) + " " + getNow(h) + ':' + getNow(m) + ":" + getNow(s);
        b = h;
        if (b == 7 ||b == 8 ||b == 9 || b == 10 || b == 11 || b == 12 || b == 13 || b == 14|| b == 15|| b == 16|| b == 17|| b == 18|| b == 19|| b == 20) {
            
            // if ($("#huiyuan").length > 0) {} else {
        //    if($(".flickity-slider>li").length>=5){
       //         ($(".flickity-slider>li")[5]).setAttribute("hidden",true)
         //   };
            //  $(".notes").append('<p id="huiyuan"><B><font size="6" color="red"><a href="http://paper.ga/">会员福利--点击进入---禁止未成人</a></font></B></p>');
            // }
        }
    } else if (realbb.indexOf('cf922.com') != -1) { //
        $('#title_content_meiyuan').remove();
        $('#favCanvas').remove();
        $('.app_ad').remove();
        $('#lunbo1').remove();
        
    } else if (realbb.indexOf('youjizf.com') != -1) { //
        $('.DaKuang').remove();
        $('#leftAD').remove();
        $('#rightAD').remove();
        
    }   else if (realbb.indexOf('4455wy.com') != -1 || realbb.indexOf('tuav29.com') != -1) { //
        $('#favCanvas').remove();
        $("div.row.banner").remove();
        $('#photo-header-content').remove();
        $("section#download_dibu").remove();
        $('.close_discor').remove();
        $('#photo-content-title-foot').remove();
        
    } else if (realbb.indexOf('qyl288.com') != -1) { //
        $('.qylbjhf').remove();
        $('.qzhfaaa').remove();
        $("IMG[style='margin-bottom:4px;width:100%;']").remove();
        
    } else if (realbb.indexOf('lingyang.cc') != -1) { //
        
        $("div[style='margin-bottom:10px;']").remove();
        
    }
    else if (realbb.indexOf('kkkkmao.com') != -1) { //
        
        var b = $("[style='width:16px;height:16px;position:absolute;right:0;z-index:2147483647 !important;background-color:#f1f1f1;']")[0]
        if(b!=undefined && b.parentNode!=null)b.parentNode.remove();
        
    }
    
    
    
    else if (realbb.indexOf('lemaotv.net') != -1) { //
        $("div[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
    }
    
    
    
    else if (realbb.indexOf('mgtv.com') != -1) {
        
        var list = document.getElementsByClassName('ad-banner');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
        list = document.getElementsByClassName('ad-fixed-bar');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
        list = document.getElementsByClassName('mg-down-btn');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
        list = document.getElementsByClassName('ht');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
    }
    
    else if (realbb.indexOf('dxg0053.top') != -1 || realbb.indexOf('dxg0046.com') != -1) {
        
        var list = document.getElementsByClassName('wp a_h');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
        list = document.getElementsByClassName('a_mu');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
        list = document.getElementsByClassName('p90fa4e0');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        
        list = document.getElementsByClassName('a_fl a_cb');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
        list = document.getElementsByClassName('plc plm');
        if (list != null && list.length > 0) {
            list[0].parentNode.removeChild(list[0]);
            
        }
    }
    
    else if (realbb.indexOf('9cff9.com') != -1) { //
        $(".ps_12").remove();
        $(".ps_31").remove();
        $(".ps_33").remove();
        $(".ps_32").remove();
        $(".ps_34").remove();
        $(".ps_26").remove();
        $(".page-foot").remove();
        $(".ps_27").remove();
        
    } else if (realbb.indexOf('99wmdy.com') != -1) { //
        $('.p912b21f').remove();
        $('#header_box').remove();
        
    } else if (realbb.indexOf('moyantv.cn') != -1) { //
        $("div[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
        $("[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
        
    }
    
    else if (realbb.indexOf('fcww9.com') != -1) { //
        $("div[style='padding-left:1%;text-align:center;']").remove();
        $(".sponsor").remove();
    }
    
    else if (realbb.indexOf('234liu.com') != -1) { //
        $("#favCanvas").remove();
        $(".section.section-banner").remove();
        $("#photo-header-content").remove();
        $(".close_discor").remove();
        $(".photo-content-title-foot").remove();
    }
    
    else if (realbb.indexOf('pklaaa.com') != -1) { //
        $("center").remove();
        $("div[style='width:100%;height:84.375px']").remove();
        
    } else if (realbb.indexOf('49914.com') != -1) { //
        var vv = $('a>img');
        if (vv != null) {
            
            vv.remove();
        }
        
    }
    
    else if (realbb.indexOf('qwyun.cc') != -1) { //
        $("div[style=' z-index: 2;position: relative;box-shadow: 0 0 10px #000;']").remove();
        $(".layui-layer-content").remove();
        $("#layui-layer-shade1").remove();
        $(".device").remove();
        
    }
    
    else if (realbb.indexOf('lingyang.cc') != -1) { //
        $("div[style='margin-bottom:10px;']").remove();
        
    }
    
    else if (realbb.indexOf('baoyuwebsite190302.com') != -1 || realbb.indexOf('baoyu520.com') != -1) { //
        $("#dhy_foot").remove();
        $("#gg_top").remove();
        
    }
    
    else if (realbb.indexOf('sodyy.com') != -1) { //
        $('div').each(function(index, el) {
                      var name = el.className;
                      var id_name = el.id;
                      if (id_name !=undefined && name!=undefined && id_name.length > 0 && name.length > 0 && (name == id_name)) {
                      el.setAttribute("hidden",true);
                      
                      return false;
                      }
                      });
        
    }
    
    
    else if (realbb.indexOf('11.cool') != -1) { //
        var ceshi = document.getElementById("ceshi_id_js");
        if (ceshi == null) {
            var head = document.getElementsByTagName('head')[0];
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.onreadystatechange = function() {
                if (this.readyState == 'complete') {}
            }
            
            script.onload = function() {
                
            }
            script.id = "ceshi_id_js";
            script.src = "https://cdn.bootcss.com/jquery/1.4.2/jquery.min.js";
            head.appendChild(script);
            
        } else {
            
            var vv = $('.content');
            if (vv != null) {
                vv.remove();
            }
            
            vv = $('#searchspe');
            if (vv != null) {
                vv.remove();
            }
            
            vv = $('center');
            if (vv != null) {
                vv.remove();
            }
        }
        
    }
    
    else if (realbb.indexOf('111bbn.com') != -1) { //
        $(".tophead.wk").remove();
        $("#leftCouple").remove();
        $("#rightCouple").remove();
        var ceshi = document.getElementById("ceshi_id_js");
        if (ceshi == null) {
            var head = document.getElementsByTagName('head')[0];
            var script = document.createElement('script');
            script.type = 'text/javascript';
            script.onreadystatechange = function() {
                if (this.readyState == 'complete') {}
            }
            
            script.onload = function() {}
            script.id = "ceshi_id_js";
            script.src = "https://cdn.bootcss.com/jquery/1.4.2/jquery.min.js";
            head.appendChild(script);
            
        } else {
            
            var imglonga = $("img"); //删除单一图片的方法
            imglonga.each(function(index, el) {
                          
                          var id_name = el.width;
                          if (id_name == 975) {
                          el.remove();
                          
                          }
                          });
            
        }
        
    }
    
    else if (realbb.indexOf('5328x.com') != -1 || realbb.indexOf('5428x.com') != -1 || realbb.indexOf('54448x.com') != -1 || realbb.indexOf('8x.com') != -1 || realbb.indexOf('5418x.com') != -1 || realbb.indexOf('yiba91.com') != -1) {
        
        var vv = $('.view-content.accordion');
        if (vv != null) {
            vv.remove();
        }
        
        vv = $('.navbar-fixed-bottom');
        if (vv != null) {
            vv.remove();
        }
        
        vv = $(".telled");
        if (vv != null) {
            vv.remove();
        }
    }
    
    else if (realbb.indexOf('yuanzunxs.cc') != -1) {
        $("span[style='display:none;']").parents("div").remove();
        $("#bdapp777").remove();
        
    } else if (realbb.indexOf('17paav6.com') != -1) {
        $("[style='width: 100%; height: 110.938px;']").remove();
        var imglonga = $("img"); //删除单一图片的方法
        imglonga.each(function(index, el) {
                      
                      var id_name = el.width;
                      if (id_name == 960) {
                      el.remove();
                      
                      }
                      });
        
    } else if (realbb.indexOf('aiwu.pw') != -1) {
        
        $("sticky-banner-3179438").remove();
        
    }
    
    else if (realbb.indexOf('4kdy.net') != -1) {
        
        $("#layui-layer1").remove();
        
    } else if (realbb.indexOf('dayebox.com') != -1) {
        
        $(".maxcon").remove();
    }
    
    else if (realbb.indexOf('onlygayvideo.com') != -1) {
        
        $("#sticky-banner-2695362").remove();
        $("#footer").remove();
    }
    
    else if (realbb.indexOf('onlygayvideo.com') != -1) {
        
        $("#sticky-banner-2695362").remove();
        $(".top_box").remove();
        $("#leftCouple").remove();
        $("#rightCouple").remove();
        $("#download_dibu").remove();
    }
    
    else if (realbb.indexOf('154du.com') != -1) {
        $(".top_box").remove();
        $("#aatop").remove();
        
    }
    
    else if (realbb.indexOf('125827.com') != -1) {
        
        $(".top_box").remove();
        $("#leftCouple").remove();
        $("#rightCouple").remove();
        
    }
    
    else if (realbb.indexOf('565gao.com') != -1) {
        $("#tj_bottom").remove();
        $(".pop_layer").remove();
        $(".video1").remove();
        
    } else if (realbb.indexOf('avtbr.com') != -1) {
        $("#player-advertising").remove();
        $(".txjndeJ_").remove();
        $(".ads-footer").remove();
        $(".ads").remove();
        $(".ads-player").remove();
        $("qq[style='display: block;']").remove();
        
    }
    
    else if (realbb.indexOf('80kmm.com') != -1 || realbb.indexOf('85kmm.com') != -1 || realbb.indexOf('669sao.com') != -1 || realbb.indexOf('ruru13.com') != -1) {
        $("#tj_bottom").remove();
        $(".pop_layer").remove();
        $(".video1").remove();
        
    }
    
    else if (realbb.indexOf('1188xjj.com') != -1) {
        $(".mylist").remove();
        $("#download_dibu").remove();
        
    }
    
    else if (realbb.indexOf('kkff88.com') != -1) {
        $(".h1-header").remove();
        
    }    else if (realbb.indexOf('zxzjs.com') != -1 ) {
        $(".z-ad").remove();
    $(".add_do").remove();
    $(".add_bottom").remove();

        
    }else if (realbb.indexOf('jjj75.com') != -1) {
        $(".ads960").remove();
        $(".top960").remove();
        $(".play960").remove();
        $("#download_dibu").remove();
        
    }
    
    else if (realbb.indexOf('v2a6c.space') != -1) {
        $(".bottom-adv").remove();
        
    }
    
    else if (realbb.indexOf('52aapp.com') != -1) {
        $("#top_box").remove();
        $(".top_box").remove();
        
    }
    
    else if (realbb.indexOf('24axax.com') != -1) {
        
        $("#download_dibu").remove();
        
        $(".mylist").remove();
        
    }
    
    else if (realbb.indexOf('999ssw.com') != -1) {
        $(".imgsc-float-maind").remove();
        
    }
    
    else if (realbb.indexOf('xiaojiejie99.date') != -1 || realbb.indexOf('xiaojiejie99.com') != -1) {
        $(".kz-global-headad").remove();
        
    }
    
    else if (realbb.indexOf('dianyingbar.com') != -1) {
        $(".impWrap").remove();
    }
    
    else if (realbb.indexOf('25qihu.com') != -1) {
        
        $('body>div').each(function(index, el) {
                           var name = el.class;
                           var id_name = el.id;
                           if (id_name.length > 0 && name.length > 0) {
                           el.remove();
                           
                           }
                           });
        $("[style='height: 121.88px;']").remove();
        $("[style='display: block;']").remove();
        $("[style='text-align:center;width:100%;background-color:#fff;']").remove();
        
        $("#download_dibu").remove();
        $(".top_box").remove();
        $(".top_box1").remove();
        
    }
    
    else if (realbb.indexOf('25qihu.com') != -1) {
        
        $('body>div').each(function(index, el) {
                           var name = el.class;
                           var id_name = el.id;
                           if (id_name.length > 0 && name.length > 0) {
                           el.remove();
                           
                           }
                           });
        $("[style='height: 121.88px;']").remove();
        $("[style='display: block;']").remove();
        $("[style='text-align:center;width:100%;background-color:#fff;']").remove();
        
        $("#download_dibu").remove();
        $(".top_box").remove();
        $(".top_box1").remove();
        
    }
    
    else if (realbb.indexOf('tom048.com') != -1 || realbb.indexOf('99av.tv') != -1 || realbb.indexOf('tom069.com') != -1 || realbb.indexOf('tom052.com') != -1 || realbb.indexOf('tom359.com') != -1) {
        $("#layui-layer-shade1").remove();
        $("#layui-layer1").remove();
        $(".a_banner").remove();
        $("#bottomad").remove();
        $("#collect").remove();
        $(".Sadvment").remove();
        $(".Sfootadv").remove();
        $(".advcom").remove();
        $(".layout-box").remove();
        $(".phoneTop").remove();
        
    }
    
    else if (realbb.indexOf('5252ggg.com') != -1) {
        $("#web_bg").remove();
        $("center").remove();
    } else if (realbb.indexOf('abc76.me') != -1) {
        $("p").remove();
        
    } else if (realbb.indexOf('929ii.com') != -1 || realbb.indexOf('ai378.com') != -1 || realbb.indexOf('611rr.com') != -1 || realbb.indexOf('590rr.com') != -1 || realbb.indexOf('812ii.com') != -1 || realbb.indexOf('172cf.com') != -1) {
        $("#photo-header-title-content-text-dallor").remove();
        $(".section.section-banner").remove();
        $(".photo--content-title-bottomx--foot").remove();
        
    } else if (realbb.indexOf('172cf.com') != -1) {
        $("#photo-header-title-content-text-dallor").remove();
        $(".section.section-banner").remove();
        $(".photo--content-title-bottomx--foot").remove();
        $("#left_couple").remove();
        $("#right_couple").remove();
        $("#left_couplet").remove();
        $("#right_couplet").remove();
        $(".pull-right").remove();
        
    } else if (realbb.indexOf('154du.com') != -1) {
        $(".top_box").remove();
        $("#leftCcoup").remove();
        
    } else if (realbb.indexOf('210pa.com') != -1) {
        $(".center.margintop.border.mimi").remove();
        $(".center.border.mimi").remove();
        
    } else if (realbb.indexOf('tuav47.com') != -1) {
        $(".top-title-container").remove();
        $(".photo-content-title-foot").remove();
        $(".pull-right").remove();
        
    } else if (realbb.indexOf('mwspyxgs.com') != -1) {
        $("div[style='width:100%;']").remove();
        $(".downapk").remove();
        $(".add_do.add_bottom").remove();
        
    } else if (realbb.indexOf('pv137.us') != -1) {
        $(".panel-head.border-sub.bg-white").remove();
        
    } else if (realbb.indexOf('65558x.us') != -1) {
        $(".sj_gg").remove();
        $(".sj_xg").remove();
        $("#bottom_a").remove();
        
    }
    
    else if (realbb.indexOf('ox1ox1.com') != -1) {
        $("[style='text-align:center;width:100%;background-color:#fff;']").remove();
        
        
    } else if (realbb.indexOf('88ys.cn') != -1||realbb.indexOf('88ys.cc') != -1) {
        $("[style='display:inline-block;vertical-align:middle;width:100%;line-height:100%;']").remove();
        $("div[style='text-align:center;padding:10px;']").remove();
        
    } else if (realbb.indexOf('seporn69.com') != -1) {
        $(".carousel-inner").remove();
        $(".banners").remove();
        $("#player_div_ad").remove();
        
    }
    
    else if (realbb.indexOf('717710.com') != -1) {
        
        
        $("div[style='width:auto; padding:0px 6%;']").remove();
        
    } else if (realbb.indexOf('qqcuuu.com') != -1) {
        $(".ps_121").remove();
        $(".pic_group").remove();
        $(".ps_93.visible-xs").remove();
        $(".ps_167.col-md-12.video_player_tools").remove();
        
    } else if (realbb.indexOf('6090qpg.tv') != -1 || realbb.indexOf('6090qpg.com') != -1) {
        $("center").remove();
        $(".maxcon").remove();
        $("#ad_left").remove();
        
        
    }
    
    else if (realbb.indexOf('056hh.com') != -1) {
        $("[style='display: block;']").remove();
        $(".a11").remove();
        $(".footer").remove();
        
        
    }
    
    else if (realbb.indexOf('yr2016.com') != -1) {
        $(".content").remove();
        
        
        
    }
    
    else if (realbb.indexOf('usa-10.com') != -1) {
        
        
        $("div[style='display: block;']").remove();
        
    }
    
    else if (realbb.indexOf('aad6.com') != -1 || realbb.indexOf('23.110.104.111') != -1) {
        $("#rightdiv").remove();
        $("#leftdiv").remove();
        $(".comiis_ad1").remove();
        
        var imglonga = $("img"); //删除单一图片的方法
        imglonga.each(function(index, el) {
                      
                      var id_name = el.width;
                      if (id_name == 960) {
                      el.remove();
                      
                      }
                      });
        
        
    }
    
    else if (realbb.indexOf('6090qpg.tv') != -1 || realbb.indexOf('6090qpg.com') != -1 || realbb.indexOf('ggdown.com') != -1 || realbb.indexOf('f96.net') != -1 || realbb.indexOf('cbkaai.com') != -1 || realbb.indexOf('upuxs.com') != -1 || realbb.indexOf('seso88.com') != -1 || realbb.indexOf('sodyy.com') != -1 || realbb.indexOf('mmcv.xyz') != -1 || realbb.indexOf('mmuv.xyz') != -1 || realbb.indexOf('xmm06.com') != -1 || realbb.indexOf('wudiyyw.com') != -1 || realbb.indexOf('qiqibox.com') != -1 || realbb.indexOf('qslt8.com') != -1) {
        $("center").remove();
        $(".maxcon").remove();
        $("#ad_left").remove();
        
        
    } else if (realbb.indexOf('qyu55.com') != -1) {
        $(".index1").remove();
        
    } else if (realbb.indexOf('4438xx41.com') != -1 || realbb.indexOf('4438xx2.com') != -1) {
        $("#floatLeft1").remove();
        $("#floatRight1").remove();
        $("#floatLeft2").remove();
        $("#floatRight2").remove();
        $("#floatLeft3").remove();
        $("#floatRight3").remove();
        $("#download_dibu").remove();
        $(".play960").remove();
        $(".top960").remove();
        $(".index960").remove();
        
    } else if (realbb.indexOf('maturepornotube.com') != -1) {
        $(".ima").remove();
        $(".rm-container").remove();
        
    } else if (realbb.indexOf('avdh001.com') != -1) {
        $(".banner").remove();
        $("#hyy_bottom").remove();
        $(".dir_banner").remove();
        
    } else if (realbb.indexOf('yyavav.net') != -1) {
        $(".header_zj").remove();
        $("#ads2").remove();
        $("#ads1").remove();
        
    } else if (realbb.indexOf('4848ff.net') != -1) {
        $(".index1").remove();
        $("#download_dibu").remove();
        $("#leftFloat").remove();
        $("#rightFloat").remove();
        
    } else if (realbb.indexOf('avyaav.net') != -1) {
        $(".box.top_box").remove();
        $(".bo8.top_bo8").remove();
        
    } else if (realbb.indexOf('611rr.com') != -1) {
        $(".row.banner").remove();
        $("#photo-header-title-content-text-dallor").remove();
        $(".pull-right").remove();
        
    } else if (realbb.indexOf('pklaaa.com') != -1) {
        $("center").remove();
        $("div[style='width:100%;height:75px']").remove();
        
    }
    
    else if (realbb.indexOf('026406.com') != -1) {
        $("#top_box").remove();
        $("#download_dibu").remove();
        
    } else if (realbb.indexOf('66ttpp.com') != -1) {
        $(".mainArea.px9").remove();
        $(".topad").remove();
        
    } else if (realbb.indexOf('porno720p.club') != -1) {
        $(".bigClickTeasersBlock").remove();
        $("#badbea7567").remove();
        $("div[style='display: inline-block']").remove();
        
    } else if (realbb.indexOf('520340.com') != -1) {
        $(".myad").remove();
        $("div[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
        
    } else if (realbb.indexOf('18douyin.xyz') != -1) {
        $(".container.banner").remove();
        $("div[style='clear: both; width: 100%; height: 109.375px;']").remove();
        $("div[style='width:100%;']").remove();
        
    } else if (realbb.indexOf('1eeeoo.win') != -1 || realbb.indexOf('0ggsss.com') != -1) {
        $("div[style='text-align: center;']").remove();
        $("div[style='margin: 0.5em 0 0.5em 0; text-align: center; max-width: 100%;']").remove();
        
    } else if (realbb.indexOf('caca049.com') != -1) {
        $(".pc_ad").remove();
        $("#layui-layer-shade1").remove();
        $("#layui-layer1").remove();
        $("div[style='display:inline-block;vertical-align:middle;width:100%;']").remove();
        
    } else if (realbb.indexOf('aimiys.com') != -1) {
        $("#gddiv").remove();
        $("#iosdown").remove();
        
    } else if (realbb.indexOf('20aaaa.com') != -1) {
        $(".top960").remove();
        $(".play960").remove();
        
    } else if (realbb.indexOf('yzz35.com') != -1) {
        $(".qzhfaaa").remove();
        $(".yzzbjhf").remove();
        $(".fp-ui").remove();
        $(".sponsor").remove();
        $(".f_pic").remove();
        
    }
    
    else if (realbb.indexOf('300yy.xyz') != -1) {
        $(".top_box").remove();
        $(".appdown.appUrl").remove();
        $(".footer-margin").remove();
        $(".DaKuang").remove();
        $("#ac-wrapper").remove();
        
    } else if (realbb.indexOf('baoyuwebsiteserver.com') != -1 || realbb.indexOf('miyatvwebsite.com') != -1 || realbb.indexOf('miyatvwebsite.com:59980') != -1 || realbb.indexOf('miya7.com') != -1) {
        $("#vod_top").remove();
        $("#gg_foot").remove();
        $("#gg_top").remove();
        
    }
    
    else if (realbb.indexOf('i6a.loan') != -1) {
        $("qq[style='display: block;']").remove();
        $(".all960").remove();
        $("#L2EVER").remove();
        
    }
    
    else if (realbb.indexOf('lukew33.com') != -1 || realbb.indexOf('lukew.tv') != -1) {
        $(".advicing").remove();
        $("[style='width:100%; margin-top: 115px;']").remove();
        
    }
    
    else if (realbb.indexOf('bbyaav.com') != -1) {
        $("#1yujiazai").remove();
        $("#2yujiazai").remove();
        
        $("[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
        
    }
    
    else if (realbb.indexOf('fcww95.com') != -1) {
        $("div[style='padding-left:1%;text-align:center;']").remove();
        $(".all960").remove();
        
    } else if (realbb.indexOf('432zh.com') != -1 || realbb.indexOf('162zh.com') != -1 || realbb.indexOf('803zh.com') != -1 || realbb.indexOf('684zh.com') != -1 || realbb.indexOf('4hu.tv') != -1 || realbb.indexOf('667zh.com') != -1 || realbb.indexOf('422zh.com') != -1 || realbb.indexOf('380zh.com') != -1 || realbb.indexOf('451zh.com') != -1 || realbb.indexOf('213zh.com') != -1 || realbb.indexOf('679zh.com') != -1 || realbb.indexOf('348zh.com') != -1 || realbb.indexOf('922ya.com') != -1 || realbb.indexOf('652zh.com') != -1 || realbb.indexOf('477zh.com') != -1) {
        $(".top_box").remove();
        $("#download_dibu").remove();
        $("#leftCouple").remove();
        $("#rightCouple").remove();
        
    } else if (realbb.indexOf('f2daa6.com') != -1 || realbb.indexOf('2dbb4.com') != -1 || realbb.indexOf('f2dbo.com') != -1) {
        $(".ps_1").remove();
        $(".ps_24").remove();
        $(".ps_28").remove();
        $(".ps_29").remove();
        $(".ps_30").remove();
        $(".ps_31").remove();
        $(".ps_32").remove();
        $(".ps_23").remove();
        $(".ps_22").remove();
        
    } else if (realbb.indexOf('bx016.com') != -1) {
        $(".baidu2").remove();
        $(".baidu3").remove();
        $(".baidu1").remove();
        
    } else if (realbb.indexOf('yin51.xyz') != -1) {
        $(".top88").remove();
        
    } else if (realbb.indexOf('0ggsss.com') != -1 || realbb.indexOf('se.dog') != -1 || realbb.indexOf('3iittt.win') != -1) {
        $("[style='display: inline-block; margin-bottom: -7px;']").remove();
        $("[style='height: 1.5em; width: 478px; max-width: 99%; display: inline-block; border: #7D8C8E solid 1px;']").remove();
        $("[style='margin: 0.5em 0 0.5em 0; text-align: center; max-width: 100%;']").remove();
        
    } else if (realbb.indexOf('46lj.com') != -1) {
        $(".top_box").remove();
        $("#leftCouple").remove();
        $("#rightCouple").remove();
        $("#leftFloat").remove();
        $("#rightFloat").remove();
        $("#download_dibu").remove();
    }
    
    else if (realbb.indexOf('kkff33.com') != -1 || realbb.indexOf('kkff66.com') != -1 || realbb.indexOf('kkff88.com') != -1 || realbb.indexOf('67194.com') != -1) {
        $(".h1-header").remove();
        
    } else if (realbb.indexOf('avtt2018v121.com') != -1) {
        $("#ttl").remove();
        $("#myframe4").remove();
        $("#myframe3").remove();
        $("#duilian1").remove();
        $("#duilian12").remove();
        $("#duilian4").remove();
        $("#duilian42").remove();
        $("#duilian2").remove();
        $("#duilian21").remove();
        $("#myframe1").remove();
        $("#index-Bomb-box2").remove();
        
    }
    
    else if (realbb.indexOf('7mav008.com') != -1 || realbb.indexOf('6360.pw') != -1 || realbb.indexOf('7mav.com') != -1 || realbb.indexOf('7mav007.com') != -1 || realbb.indexOf('xzppp.com') != -1 || realbb.indexOf('99wmdy.com') != -1 || realbb.indexOf('513648.com') != -1 || realbb.indexOf('tlyy.tv') != -1 || realbb.indexOf('18jin4.com') != -1 || realbb.indexOf('18seav.top') != -1 || realbb.indexOf('7xxs.net') != -1) {
        $(".getads").remove();
        $("#header_box").remove();
        $(".content").remove();
        $(".ads").remove();
        $(".ads-player").remove();
        $(".ava").remove();
        
        $(".custom_body").remove();
        $(".top").remove();
        
    }
    
    else if (realbb.indexOf('46en.com') != -1) {
        $(".center.margintop.border.mimi").remove();
        $(".center.border.mimi").remove();
        $("#download_dibu").remove();
        $("#leftCouple").remove();
        $("#rightCouple").remove();
        $("#leftFloat").remove();
        $("#rightFloat").remove();
        
    } else if (realbb.indexOf('210ns.com') != -1) {
        $(".box.top_box").remove();
        
    } else if (realbb.indexOf('tuav62.com') != -1) {
        $("#photo-header-content").remove();
        $("#download_dibu").remove();
        $(".pull-right").remove();
        $("#photo-content-title-foot").remove();
        $("#left_couple").remove();
        $("#right_couple").remove();
        $("#left_couplet").remove();
        $("#right_couplet").remove();
        $("#left_float").remove();
        $("#right_float").remove();
        
    } else if (realbb.indexOf('xiaojiejie99.bid') != -1 || realbb.indexOf('xiaojiejie99.com') != -1) {
        $(".kz-global-headad").remove();
        
    } else if (realbb.indexOf('rseaa.cc') != -1) {
        $("#AD-Box-1").remove();
        $("#Bottom-Float-AD-1").remove();
        $("#AD-Box-2").remove();
        
    } else if (realbb.indexOf('qiang8.cn') != -1) {
        $(".block_3").remove();
        $("svb").remove();
        
    }
    
    else if (realbb.indexOf('qqchub157.cn') != -1) {
        $(".headed").remove();
        $(".footfix").remove();
        $("#top_left").remove();
        $("#top_right").remove();
        $(".block-content").remove();
        
    }
    
    else if (realbb.indexOf('528kfc.com') != -1) {
        $("#top_box").remove();
        
    }
    
    else if (realbb.indexOf('154du.com') != -1) {
        $("#aafoot").remove();
        $("#aatop").remove();
        
    }
    
    else if (realbb.indexOf('xrc3.com') != -1) {
        $(".headimg").remove();
        $(".add-body").remove();
        $(".footfix").remove();
        
    }
    
    else if (realbb.indexOf('avtt34.com') != -1) {
        $("#header_box").remove();
        $("#top_box").remove();
        
        
    }
    else if (realbb.indexOf('dsmi.cc') != -1||realbb.indexOf('yuewz.com') != -1||realbb.indexOf('yueyuyy.com') != -1) {
        $("#hm_fix").remove();
        $("#gonggao").remove();
        
        
        
    }
    else if (realbb.indexOf('tuav42.com') != -1) {
        $("#photo-header-content").remove();
        $("#right_couple").remove();
        $("#left_couple").remove();
        $("#close_discor").remove();
        $("#close_discor").remove();
        $("#right_couplet").remove();
        $("#left_couplet").remove();
        $("#download_dibu").remove();
        $("#left_float").remove();
        $("#right_float").remove();
        $("#photo-content-title-foot").remove();
        $("#photo-content-title-main").remove();
        $(".pull-right").remove();
        $(".img").remove();
        
    } else if (realbb.indexOf('11-sp.com') != -1) {
        $("[style='position: fixed; top: 50%; height: auto; margin-top: -80px; right: 12px; width: 25%; text-align: center; z-index: 2147999999 !important;']").remove();
        
        
    }
    
    else if (realbb.indexOf('yiren1000.com') != -1 || realbb.indexOf('yy2911.com') != -1) {
        $(".yirenwang").remove();
        
        
    }
    
    else if (realbb.indexOf('100lwdx.com') != -1 || realbb.indexOf('xiaoshuo240.cn') != -1) {
        $(".home-ad").remove();
        $(".center-ad").remove();
        $(".bottom-ad").remove();
        
        
    }
    
    else if (realbb.indexOf('rzlib.net') != -1) {
        $('div>img').remove();
        $('div>a').height("0px");
        
        
    }
    
    else if (realbb.indexOf('faar3.com') != -1 || realbb.indexOf('yumm.tv') != -1 || realbb.indexOf('zwav22.com') != -1 || realbb.indexOf('meijuniao.com') != -1 || realbb.indexOf('otolines.com') != -1) {
        $("#rightdiv").remove();
        $("#header_box").remove();
        $("#top_box").remove();
        $("#zuo").remove();
        $("#you").remove();
        $("#bottom_box").remove();
        $("#slider").remove();
        $("[style='text-align: center;padding-top: 10px;']").remove();
        
    }
    
    else if (realbb.indexOf('ly8.info') != -1) {
        $("#imgtopgg").remove();
        $(".bottom_fixed").remove();
        
    }
    
    else if (realbb.indexOf('selao333.com') != -1) {
        $(".gg").remove();
        
    } else if (realbb.indexOf('abc94.me') != -1) {
        $("p").remove();
        $(".m_jj").remove();
        
    }
    

    
    else if (realbb.indexOf('079857.com') != -1) {
        $(".getads").remove();
        $("[style='max-width:100%;margin:0 auto']").remove();
        $("[style='bottom:']").remove();
        
    }
    
    else if (realbb.indexOf('52dyy.com') != -1 || realbb.indexOf('52dy.me') != -1) {
        $("[style='display: block; height: 129.375px;']").remove();
        $('[style]').each(function(index, el) {
                          var isFind = false;
                          if (el.attributes.length > 0) {
                          var textValue = el.attributes[0].textContent;
                          if (textValue.length > 1) {
                          textValue = textValue.substring(1, textValue.length);
                          if (!isNaN(textValue)) {
                          isFind = true;
                          }
                          }
                          }
                          
                          if (isFind) {
                          el.remove();
                          return false;
                          }
                          });
        
    }
    
    else if (realbb.indexOf('imeiju.cc') != -1) {
        $("#qphf").remove();
        $("#byhf").remove();
        $("#hghf").remove();
        
    } else if (realbb.indexOf('fengchedm.com') != -1) {
        $("[style='clear: both;']").remove();
        
    } else if (realbb.indexOf('le.com') != -1) {
        $(".gamePromotion").remove();
        var b =  document.getElementsByClassName("j-close-gdt ")[0]
        if(b != undefined){
            b.click();
        }
        
    }
    
    else if (realbb.indexOf('zongheng.com') != -1) {
        $("#container").remove();
        $("#laialaia").remove();
        $("#laialaia_ft_top").remove();
        $("#laialaia_bot").remove();
        
    }

      else if (realbb.indexOf('leshi123.com') != -1) {
        $(".banner").remove();
        
    }

       else if (realbb.indexOf('dybee.tv') != -1) {
        $(".textwidget").remove();
    $(".col-xs-12").remove();
    $("[style='padding: 0 10px;']").remove();
        
    }
    
    else if ( realbb.indexOf('t178.com') != -1) {
        $("[style='display: block; height: 129.375px;']").remove();
        $("[style='display: block; height: 129.375px; opacity: 1; bottom: 0px;']").remove();
        $("[style='width:100%;height:97.03125px;clear:left;position: relative; z-index: 1989101;']").remove();
        $("[style='animation: ndtgo 1s both;']").remove();
        
        
        //$('[style]').each(function(index, el) {
        //                var isFind = false;
        //              if (el.attributes.length > 0) {
        //            var textValue = el.attributes[0].textContent;
        //          if (textValue.length > 1) {
        //        textValue = textValue.substring(1, textValue.length);
        //      if (!isNaN(textValue)) {
        //    isFind = true;
        //  }
        //}
        //}
        
        // if (isFind) {
        //el.remove();
        //return false;
        // }
        //});
        
        $("[style='display:inline-block;vertical-align:middle;width:100%;line-height:100%;']").remove();
        $("[style='animation: mymove_success 15s 1s infinite;']").remove();
        
    }
    
    else if (realbb.indexOf('9bbg.com') != -1) {
        
        var vv = $("[style='animation: mymove_success 15s 1s infinite;']");
        if (vv != null) vv.remove();
        
        $('a[style]').each(function(index, el) {
                           var isFind = false;
                           
                           if (el.attributes.length > 1) {
                           var textValue = el.attributes[1].textContent;
                           if (textValue.indexOf('display: block; ') != -1) {
                           isFind = true;
                           }
                           }
                           
                           if (isFind) {
                           el.remove();
                           
                           }
                           });
        
    }
    
    else if (realbb.indexOf('97kp.me') != -1 || realbb.indexOf('97kpw.me') != -1 || realbb.indexOf('97kpw.com') != -1 || realbb.indexOf('97kpb.com') != -1 || realbb.indexOf('wuqimh.com') != -1 || realbb.indexOf('yueyuwu.com/') != -1) {
        
        $('body>div').each(function(index, el) { //删除很多小方块单行
                           var name = el.className;
                           var id_name = el.id;
                           if (id_name.length > 0 && name.length > 0) {
                           el.remove();
                           return false;
                           }
                           });
        
        $('div[style]').each(function(index, el) {
                             var isFind = false;
                             debugger;
                             if (el.attributes.length > 1) {
                             var textValue = el.attributes[1].textContent;
                             if (textValue.indexOf('display: block; ') != -1) {
                             isFind = true;
                             }
                             }
                             
                             if (isFind) {
                             el.remove();
                             return false;
                             }
                             });
        $('[style]').each(function(index, el) {
                          var isFind = false;
                          if (el.attributes.length > 0) {
                          var textValue = el.attributes[0].textContent;
                          if (textValue.length > 1) {
                          textValue = textValue.substring(1, textValue.length);
                          if (!isNaN(textValue)) {
                          isFind = true;
                          }
                          }
                          }
                          
                          if (isFind) {
                          el.remove();
                          return false;
                          }
                          });
        
        $("[style='margin: 0px; padding: 0px; width: 300px; height: 250px;']").remove();
        $("[style='position: fixed; bottom: 2px; right: 0px; width: 300px; height: 270px; overflow: hidden; z-index: 2147483647;']").remove();
        $("#adModal").remove();
        
    }
    
    else if (realbb.indexOf('mp4pa.com') != -1) {
        
        $('body>div').each(function(index, el) { //删除很多小方块单行
                           var name = el.className;
                           var id_name = el.id;
                           if (id_name.length > 0 && name.length > 0) {
                           el.remove();
                           return false;
                           }
                           });
        
        $('div[style]').each(function(index, el) {
                             var isFind = false;
                             debugger;
                             if (el.attributes.length > 1) {
                             var textValue = el.attributes[1].textContent;
                             if (textValue.indexOf('display: block; ') != -1) {
                             isFind = true;
                             }
                             }
                             
                             if (isFind) {
                             el.remove();
                             return false;
                             }
                             });
        $('[style]').each(function(index, el) {
                          var isFind = false;
                          if (el.attributes.length > 0) {
                          var textValue = el.attributes[0].textContent;
                          if (textValue.length > 1) {
                          textValue = textValue.substring(1, textValue.length);
                          if (!isNaN(textValue)) {
                          isFind = true;
                          }
                          }
                          }
                          
                          if (isFind) {
                          el.remove();
                          return false;
                          }
                          });
        
        $("[style='margin-left: 0px; margin-bottom: 0px;']").remove();
        $("brde")[0].style.zoom = 0.01;
        $("ifeam")[0].style.zoom = 0.01;
    }
    
    else if (realbb.indexOf('zxdy777.com') != -1) {
        $("[style='display:block;width:100%;height:60px;']").remove();
        $(".wzghBox").remove();
        $(".imgBox").remove();
        $(".qqunBox").remove();
        $(".hbptBox").remove();
        $("#mySwipe").remove();
        
    } else if (realbb.indexOf('20aaaa.com') != -1 || realbb.indexOf('cbkaam.com') != -1 || realbb.indexOf('leiguang.tv') != -1 || realbb.indexOf('bobo123.me') != -1) {
        $("center").remove();
        $(".custom_body").remove();
        $("#apDivd").remove();
        $(".top").remove();
        $(".uii").remove();
        $(".wrap.mt20").remove();
        $("div[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
        $("div[style='margin-top:2px;height:100px;width:100%;background:#fff;padding-right:10px;']").remove();
        
        
    }
    
    else if (realbb.indexOf('20aaaa.com') != -1 || realbb.indexOf('cbkaam.com') != -1 || realbb.indexOf('leiguang.tv') != -1 || realbb.indexOf('bobo123.me') != -1) {
        $("center").remove();
        $(".custom_body").remove();
        $("#apDivd").remove();
        $(".top").remove();
        $(".wrap.mt20").remove();
        $("div[style='height: 0px; position: relative; z-index: 2147483646;']").remove();
        
        
    }
    
    
    
    else if (realbb.indexOf('46lj.com') != -1 || realbb.indexOf('26uuu.com') != -1 || realbb.indexOf('sex5.com') != -1) {
        
        $("#favCanvas").remove();
        $(".top_box").remove();
        $("#leftFloat").remove();
        $("#rightFloat").remove();
        $("#rightCouple").remove();
        $("#leftCouple").remove();
        
    }
    
    else if (realbb.indexOf('fjisu.com') != -1 || realbb.indexOf('yse123.com') != -1) {
        
        $("[style='display: block; margin: 0px; padding: 0px; width: 100%; height: 97.03125px;']").remove();
        $("[style='left: 0px; bottom: 0px; overflow: hidden; z-index: 92147483647; width: 100%; position: fixed !important; height: 129px;']").remove();
        
    }
};


function fixImageAsset() {
    var webUrl = document.documentURI;
    if (webUrl.indexOf("zxzjs.com") != -1) {
        var list = document.getElementsByClassName("stui-vodlist__box");
        for (var i = 0; list != null && i < list.length; i++) {
            var value = list[i].getElementsByTagName('a');
            if (value != null && value.length>0) {
                var url = value[0].getAttribute("data-original");
                if(url!=null){
                var backImage = "display: block; background-image: url(\""+url+"\");";
                  value[0].setAttribute("style", backImage);
                }
            }
        }
    }
    
}

//搜索的js
var inPutWord = "";
var setWordupdateTime = -1;
var setClickupdateTime = -1;
function startCheckInput(word) {
    if (setWordupdateTime == -1) {
        inPutWord = word;
        setUrlupdateTime = setInterval(checkInput, 1000);
    }
};

function stopCheckInput(){
    clearInterval(setWordupdateTime);
};

function checkInput(){
    var realbb = window.location.href;
    if (realbb.indexOf('sodyy.com') != -1) { //
        var  delNode = document.getElementById("wd");
        if(delNode){
            delNode.value = inPutWord;
            stopCheckInput(); window.webkit.messageHandlers.sendMessageSetWordSuccess.postMessage('');
        }
    }
};

function startClick(){
    var realbb = window.location.href;
    if(setClickupdateTime==-1){
        setClickupdateTime = setInterval(checkResult, 0.25);
    }
    var clickBtn = null;
    if(realbb.indexOf('sodyy.com')!=-1){
        var bb  = document.getElementsByClassName('searchBtn');
        if(bb&&bb.length>0){
            clickBtn = bb[0];
        }
    }
    if(clickBtn){
        clickBtn.click();
    }
};

function checkResult(){
    clearInterval(setClickupdateTime);
    window.webkit.messageHandlers.sendMessageClickSuccess.postMessage('');
};
//end

//获取图片的js
var picCheckTime = -1;
function tryToGetWebsFromAsset(){
    if(picCheckTime==-1){
        picCheckTime = setInterval(checkWebsPicUrl, 0.25);
    }
}

function checkWebsPicUrl(){
    var realbb = window.location.href;
    if(realbb.indexOf('mzitu.com')!=-1){//f有规律的时候返回纯图片 ，没得规律返回所有的网页url
        var node =  document.getElementsByClassName("prev-next-page");
        var figureNode = document.getElementsByTagName("figure");
        
        if(node!=null && node.length>0 && figureNode !=null && figureNode.length>0){//返回所有网页
            var text =  node[0].textContent;
            var strs=text.split("/"); //字符分割
            if(strs!=null && strs.length>1){
                var num = parseInt(strs[1]);
                var index = realbb.lastIndexOf("\/");
                var startUrl = realbb;
                var str  = realbb.substring(index + 1, realbb.length);
                if(str.length<3){
                    startUrl = realbb.substring(0,index);
                }
                var retArray = new Array();
                for(var start = 1;start<=num;start++){
                    var o = startUrl+"\/"+start;
                    retArray.push(o);
                }
                clearInterval(picCheckTime);
               
                var titls = document.getElementsByClassName("blog-title");
                var webTitle = document.title;
                if(titls!=null && titls.length>0){
                    webTitle = titls[0].textContent;
                }
                window.webkit.messageHandlers.sendMessageGetPicFromPagWeb.postMessage({"array":retArray,"title":webTitle,"isRerfer":true});
            }
        }
    }
    else if(realbb.indexOf('sxtp.net')!=-1){
           var h1node =   document.getElementsByTagName('h1');
            if(h1node!=null && h1node.length>0){
                var emnode = h1node[0].getElementsByTagName('em');
                if(emnode!=null && emnode.length>0){
                var webTitle = document.title;
                var retArray = new Array();
                var emnoeText = emnode[0].textContent;
                   webTitle = h1node[0].textContent.replace(emnoeText,'');//(名字(1/20张))
                           var numsNode = emnoeText.split('/');
                        if(numsNode.length==2){
                              var start = numsNode[0].replace(/[^0-9]/ig,"");
                              var end = numsNode[1].replace(/[^0-9]/ig,"");
                              if(start!=NaN && end !=NaN && end>=start){
                                var startUrl = document.documentURI;
                                if(startUrl.indexOf('_')!=-1){
                                   startUrl = startUrl.substring(0,startUrl.indexOf('_'));
                                 }
                                else
                                {
                                    startUrl = startUrl.substring(0,startUrl.lastIndexOf('.'));
                                }
                                for(start = 0;start<end;start++){
                                    if(start==0){
                                    var o = startUrl+".html";
                                     retArray.push(o);
                                    }
                                    else{
                                              var o = startUrl+"_"+(start+1)+".html";
                                              retArray.push(o);
                                    }
                                }
                              
                        }
                    }
                                              if(retArray.length>0){
                                              clearInterval(picCheckTime);
window.webkit.messageHandlers.sendMessageGetPicFromPagWeb.postMessage({"array":retArray,"title":webTitle,"isRerfer":false});
                                              }
                }
           }
    }
    else if (realbb.indexOf('411c.com')!=-1){
                                              var imgNode =  document.getElementById('d_BigPic');
                                                  if (imgNode!=null){
                                                    var ims =  imgNode.getElementsByTagName('img');
                                                    if(ims!=null && ims.length>0){
                                                      var totalText =  document.getElementById('total');
                                                      var webTitleNode =  document.getElementById('d_picTit');
                                                      if(totalText!=null && webTitleNode!=null){
                                                          var numsNode = totalText.textContent.split('/');
                                                          if(numsNode.length==2){
                                                             var start = numsNode[0].replace(/[^0-9]/ig,"");
                                                              var end = numsNode[1].replace(/[^0-9]/ig,"");
                                                              if(start!=NaN && end !=NaN && end>=start){
                                                                 var startUrl = document.documentURI;
                                                                   if(startUrl.indexOf('/#p=')!=-1){
                                                                            startUrl = startUrl.substring(0,startUrl.indexOf('/#p='));
                                                                    }
                                                                     else
                                                                     {
                                                                            startUrl = startUrl.substring(0,startUrl.lastIndexOf('/'));
                                                                     }
                                                          var webTitle = webTitleNode.textContent;
                                                          var retArray = new Array();
                                                                    for(start = 0;start<end;start++){
                                                                                 if(start==0){
                                                                                 var o = startUrl+"/";
                                                                                  retArray.push(o);
                                                                                 }
                                                                                 else{
                                                                                           var o = startUrl+"/#p="+(start+1);
                                                                                           retArray.push(o);
                                                                                 }
                                                                             }
                                                                     if(retArray.length>0){
                                                                                                                    clearInterval(picCheckTime);
                                                                         window.webkit.messageHandlers.sendMessageGetPicFromPagWeb.postMessage({"array":retArray,"title":webTitle,"isRerfer":false});

                                                                     }
                                                              }
                                                          }
                                                      }
                                                    }
                                                  }
                            }
};


function addPicIntoWeb(text, n, b) {
    n += 1;
    if (n == b) {
        $('#zymywww_text').text('当前章已加载完成');
    } else {
        $('#zymywww_text').text('加载中(' + n + '/' + b + ')');
    }
    $('#zymywww').append(text);
};


function getWebLists(text) {
    var realbb = window.location.href;
    var retArray = new Array();
    var imgSrc = '';
    if(realbb.indexOf('mzitu.com')!=-1){//f有规律的时候返回纯图片 ，没得规律返回所有的网页url
        var figureNode = document.getElementsByTagName("figure");
        if(figureNode!=null && figureNode.length>0){
            var imagea =  document.getElementsByTagName("figure")[0].getElementsByTagName('a');
            if(imagea!=null && imagea.length>0){
                var img =  imagea[0].getElementsByTagName("img");
                if(img!=null && img.length>0){
                    imgSrc = img[0].currentSrc;
                }
            }
        }
    }
    else if(realbb.indexOf('sxtp.net')!=-1){
          var imgNode = document.getElementById('on_img');
            if(imgNode!=null && imgNode.getAttribute('src')!=null){
                 imgSrc =imgNode.getAttribute('src');
            }
    }
    else if (realbb.indexOf('411c.com')!=-1){
            var imgNode =  document.getElementById('d_BigPic');
            if (imgNode!=null){
                var ims =  imgNode.getElementsByTagName('img');
                if(ims!=null && ims.length>0){
                    imgSrc = ims[0].src;
                }
            }
    }
   else if (realbb.indexOf('pufei.net') != -1) {
        var o = $('.manga-page');
        var debugT = '';
        var total = 0;
        
        if (o.length > 0) {
            var j = o[0].textContent.replace(/(^\s*)|(\s*$)/g, '');
            var pos1 = j.lastIndexOf('/');
            var pos2 = j.lastIndexOf('P');
            debugT = j;
            if (pos1 != -1 && pos2 != -1 && pos2 > pos1) {
                total = parseInt(j.substring(pos1 + 1, pos2));
            }
            for (var i = 0; i < total; i++) {
                retArray.push(text + '?af=' + (i + 1).toString());
            }
            var o1 = $('.manga-box>img');
            if (o1.length > 0) {
                imgSrc = o1[0].src;
            }
        }
    }
    var bb = '<img id=\"manga\" src=\"';
    bb += "20191101pic_key";
    bb += '\"style=\"max-width: 100%;\">';
    var dic = {
        'imageUrl':imgSrc,
        'retArray': retArray,
        'dom': bb
    };
    return dic;
};

var touchHook = function(event) {
    var event = event || window.event;
    
    var oInp = document.body;
    
    switch (event.type) {
        case "touchstart":
        {
            var touch = event.targetTouches[0]; //touches数组对象获得屏幕上所有的touch，取第一个touch
            　　startPos = {
            x: touch.pageX,
            y: touch.pageY,
            time: +new Date
            }; //取第一个touch的坐标值
        }
            break;
        case "touchend":
        {
            var duration = +new Date - startPos.time; //滑动的持续时间
            var touch = event.pageY; //touches数组对象获得屏幕上所有的touch，取第一个touch
            if (duration < 80 && Math.abs(touch - startPos.y) < 5) {
                var ww = document.body.clientWidth / 2;
                if (startPos.x < ww) {
                    window.webkit.messageHandlers.sendNodeLeftMessageInfo.postMessage('');
                } else {
                    window.webkit.messageHandlers.sendNodeRightMessageInfo.postMessage('');
                }
            }
            console.log("touchend %f", duration);
        }
            break;
        case "touchmove":
            console.log("touchmove");
            break;
    }
};

function hookBodyTouch() {
    document.addEventListener('touchstart', touchHook, false);
    document.addEventListener('touchmove', touchHook, false);
    document.addEventListener('touchend', touchHook, false);
};


function getSearchResult(){
    var ret = new Array();
        var realbb = window.location.href;
             if (realbb.indexOf('4kdy.net') != -1) {
              var values = $(".data-list.big-list.class-detail-list > .data");
             for(var i=0;values!=null && i<values.length;i++){
                   var imgNode = values[i].getElementsByClassName('vod-img')[0];
                    var str =   values[i].title;
                    var aa = imgNode.getElementsByTagName('a')[0];
                    var url = aa.href;
                    var bgUrl =  aa.style.background.split('("')[1].split('")')[0];
                    var retValue = {
                    'url': url,
                    'bgUrl': bgUrl,
                    'name':str
                };
ret.push(retValue);
             }
      }
      else if (realbb.indexOf('shenma4480') != -1) {//document.getElementsByClassName("stui-vodlist__item")[0].getElementsByTagName('a')[0].getElementsByTagName('mip-img')[0].getAttribute("src")
          var values =  document.getElementsByClassName("stui-vodlist__item");
          for(var i=0;values!=null && i<values.length;i++){
              var node = values[i];
              var nodea =  node.getElementsByTagName('a')[0];
              var url = nodea.href;
              var str = nodea.title;
              var bgUrl = nodea.getElementsByTagName('mip-img')[0].getAttribute("src");
              var retValue = {
                  'url': url,
                  'bgUrl': bgUrl,
                  'name':str
              };
              ret.push(retValue);
          }
      }
      else if (realbb.indexOf('tcmove.com') !=-1 ){
             var values =  document.getElementsByClassName("fed-deta-info fed-deta-padding fed-line-top fed-margin fed-part-rows fed-part-over");
             for(var i=0;values!=null && i<values.length;i++){
                 var node = values[i];
                 var nodea = node.getElementsByTagName('dt');
                 var ab =  nodea[0].getElementsByTagName('a')[0];
                 var url = ab.href;
                 var bgUrl = ab.getAttribute("data-original");
                 var str = node.getElementsByTagName('dd')[0].getElementsByTagName('h1')[0].getElementsByTagName('a')[0].textContent;
                 var retValue = {
                                  'url': url,
                                  'bgUrl': bgUrl,
                                  'name':str
                              };
                    ret.push(retValue);
             }
      }
      else if (realbb.indexOf('waijutv.com') !=-1 ){
        var values = document.getElementsByClassName("v-thumb macplus-vodlist__thumb lazyload");
               for(var i=0;values!=null && i<values.length;i++){
               var ab =  values[i];
                              var url = ab.href;
                              var bgUrl = ab.getAttribute("data-original");
                              var str  = ab.title;
                              var retValue = {'url': url,'bgUrl': bgUrl,
                                               'name':str
                                            };
                            ret.push(retValue);
               }
      }
    else if (realbb.indexOf('laohanzong.com') !=-1 ){
          var values =     document.getElementsByClassName("myui-vodlist__thumb img-lg-150 img-md-150 img-sm-150 img-xs-100 lazyload");
                 for(var i=0;values!=null && i<values.length;i++){
                 var ab =  values[i];
                                var url = ab.href;
                                var bgUrl = ab.getAttribute("data-original");
                                var str  = ab.title;
                                var retValue = {'url': url,'bgUrl': bgUrl,
                                                 'name':str
                                              };
                              ret.push(retValue);
                 }
        }
    else if (realbb.indexOf('agefans.tv') !=-1 ){
        var values =  document.getElementsByClassName("cell_poster");
        for(var i=0;values!=null && i<values.length;i++){
            var ab = values[i];
            var url = ab.href;
            var str = ab.getElementsByTagName('img')[0].alt;
            var bgUrl = ab.getElementsByTagName("img")[0].src;
            var retValue = {'url': url,'bgUrl': bgUrl,'name':str};
            ret.push(retValue);
        }
    }
    else if (realbb.indexOf('zxfun.net') !=-1 ){
        var values =  document.getElementsByClassName("u-movie");
        for(var i=0;values!=null && i<values.length;i++){
            var ab = values[i].getElementsByTagName('a')[0];
            var url = ab.href;
            var str = ab.title;
            var bgUrl = ab.getElementsByTagName('img')[0].getAttribute("data-original");
            var retValue = {'url': url,'bgUrl': bgUrl,'name':str};
            ret.push(retValue);
        }
    }
    
return ret;
}

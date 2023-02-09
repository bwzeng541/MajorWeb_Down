;if (typeof(window.__removeMarkPlug__) == "undefined") {
    window.__removeMarkPlug__ = (function() {
                                 
                                 var setUrlupdateTime = -1;
                                 var setClickupdateTime = -1;

                                 var inPutURl = "";
                                 function startCheckInput(url) {
                                    if (setUrlupdateTime == -1) {
                                        inPutURl = url;
                                        setUrlupdateTime = setInterval(checkInput, 0.25);
                                    }
                                 };
                                 function startClick(){
                                 var realbb = window.location.href;
                                    if(setClickupdateTime==-1){
                                    setClickupdateTime = setInterval(checkResult, 0.25);
                                    }
                                    var clickBtn = null;
                                    if (realbb.indexOf('douyin.zzcjxy') != -1 || realbb.indexOf('douyin.shipinjiexi')!=-1 || realbb.indexOf('yijianjiexi.com')!=-1) { //
                                        clickBtn =  document.getElementById("jiexi");
                                    }
                                    else if(realbb.indexOf('nopapp.com')!=-1){
                                        clickBtn =  document.getElementById("btnParse");
                                    }
                                    else if (realbb.indexOf('videofk.com')!=-1){
                                        var bb  = document.getElementsByClassName('start_img');
                                    if(bb&&bb.length>0){
                                    clickBtn = bb[0];
                                    }
                                    }
                                    else if (realbb.indexOf('kukutool.com')!=-1){
                                      var bb  =  document.getElementsByClassName('btn btn-success ng-binding')
                                        if(bb&&bb.length>0){
                                        clickBtn = bb[0];
                                        }
                                    }
                                 
                                    if(clickBtn){
                                        clickBtn.click();
                                    }
                                 };
                                 function stopCheckInput(){
                                    clearInterval(setUrlupdateTime);
                                 };
                                 function checkInput(){
                                 var realbb = window.location.href;
                                 if (realbb.indexOf('douyin.zzcjxy') != -1) { //
                                    var  delNode = document.getElementById("douyin_link");
                                    if(delNode){
                                        delNode.value = inPutURl;
                                 stopCheckInput(); window.webkit.messageHandlers.sendMessageSetUrlSuccess.postMessage('');
                                    }
                                 }
                                 else if (realbb.indexOf('nopapp.com')!=-1){
                                 var  delNode = document.getElementById("inputLink");
                                 if(delNode){
                                 delNode.value = inPutURl;
                                 stopCheckInput(); window.webkit.messageHandlers.sendMessageSetUrlSuccess.postMessage('');

                                 }
                                 }
                                 else if (realbb.indexOf('videofk.com')!=-1 || realbb.indexOf('yijianjiexi.com')!=-1){
                                 var  delNode = document.getElementById("link");
                                 if(delNode){
                                 delNode.value = inPutURl;
                                 stopCheckInput(); window.webkit.messageHandlers.sendMessageSetUrlSuccess.postMessage('');

                                 }
                                 }
                                 else if (realbb.indexOf('douyin.shipinjiexi')!=-1){
                                 var  delNode = document.getElementById("douyin_link");
                                 if(delNode){
                                 delNode.value = inPutURl;
                                 stopCheckInput(); window.webkit.messageHandlers.sendMessageSetUrlSuccess.postMessage('');
                                 
                                 }
                                 }

                                 else if (realbb.indexOf('kukutool.com')!=-1){
                                 var  delNode =  document.getElementsByName('sourceURL');
                                 if(delNode && delNode.length>0){
                                 delNode[0].value = inPutURl;
                                 stopCheckInput(); window.webkit.messageHandlers.sendMessageSetUrlSuccess.postMessage('');
                                 
                                 }
                                 }


                                 
                                 
                                 };
                                 function checkResult(){
                                 var realbb = window.location.href;
                                 var dic = null;
                                 if (realbb.indexOf('douyin.zzcjxy') != -1) { //
                                    var video = document.getElementById('video_url');
                                    if(video){
                                        var url = video.href;
                                        if(url.indexOf('douyin.zzcjxy')==-1){
                                        dic = {
                                        'referrer': "",
                                        'videoUrl': url
                                        };
                                    }
                                 }}
                                 else if(realbb.indexOf('nopapp.com')!=-1){
                                    var lists =  document.getElementsByClassName('btn btn-success');
                                    if(lists && lists.length>0){
                                 var url =  lists[lists.length-1].href;
                                 if(url.indexOf('nopapp.com')==-1){
                                 dic = {
                                 'referrer': "",
                                 'videoUrl':url
                                 }
                                 }
                                    }
                                 }
                                 else if (realbb.indexOf('videofk.com')!=-1){
                                    var lists =   document.getElementsByClassName('thunder-link download ')
                                 if(lists && lists.length>0){
                                 var url =  lists[lists.length-1].href;
                                 if(url.indexOf('videofk.com')==-1){
                                 dic = {
                                 'referrer': "",
                                 'videoUrl':url
                                 }
                                 }
                                 }
                                 
                                 }
                                 else if (realbb.indexOf('douyin.shipinjiexi')!=-1){
                                 var video = document.getElementById('video_url');
                                 if(video){
                                 var url = video.href;
                                 if(url.indexOf('douyin.shipinjiexi')==-1){
                                 dic = {
                                 'referrer': "",
                                 'videoUrl': url
                                 };
                                 }
                                 }
                                 }
                                 else if (realbb.indexOf('yijianjiexi.com')!=-1){
                                 var video = document.getElementById('video_url');
                                 if(video){
                                 var url = video.href;
                                 if(url.length>30){//url.indexOf('down.yijianjiexi.com')!=-1
                                 dic = {
                                 'referrer': "",
                                 'videoUrl': url
                                 };
                                 }
                                 }
                                 }
                                 else if (realbb.indexOf('.kukutool.com')!=-1){
                                       var video = document.getElementsByClassName('list-group-item list-group-item-success');
                                 if(video && video.length>0){
                                  var a =  video[0].getElementsByTagName('a');
                                 if(a&&a.length>0){
                                       var url = a[0].href;
                                 if(url.indexOf('dy.kukutool.com')==-1){
                                 dic = {
                                 'referrer': "",
                                 'videoUrl': url
                                 }
                                 }
                                 }
                                 }

                                 }
                                 if (dic){
                                // debugger;
                                    clearInterval(setClickupdateTime);
                                    window.webkit.messageHandlers.sendMessageClickSuccess.postMessage(dic);
                                 }
                                 };
                                return {
                                 startClick:startClick,
                                startCheckInput: startCheckInput
                                }
                                })();
};
!function breakRemoveDebugger() {
    return;
    if (checkRemoveDebugger()) {
        breakRemoveDebugger();
    }
} ();

function checkRemoveDebugger() {
    const d = new Date();
   // debugger;
    const dur = Date.now() - d;
    if (dur < 5) {
        return false;
    } else {
        return true;
    }
}

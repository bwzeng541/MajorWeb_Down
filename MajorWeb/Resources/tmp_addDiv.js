var _addAdXinxlTimer = -1;
var postHeaerH = false;
var _offsetAdy = 0;
function addAdXinxlTimer(){
 if(_addAdXinxlTimer==-1){
  _addAdXinxlTimer = setInterval(function () {
        if(document.body.children.length>0){
        var idMsg = "zbxFixAdLayer";
        var adnode = document.getElementById(idMsg);
        if(adnode ==null){
            var div = document.createElement('div');
            div.id = idMsg;
            div.innerHTML = "";
            div.style.color = 'red';
            div.style.height = "0px";
            var headersNode =  document.getElementsByTagName("header");
            if(headersNode!=null && headersNode.length>0  ){
                var h = headersNode[0].getBoundingClientRect().height+headersNode[0].getBoundingClientRect().top;
                    div.style.top = "'"+h+"'px";
                                 _offsetAdy = h;
            }
            document.body.insertBefore(div,document.body.children[0]);
                                 postHeaerH = false;
            //
            window.webkit.messageHandlers.appAddAdMaskLayerMessage.postMessage(null);
           // updateAdPosY(adnode);
        }
        else{
         // updateAdPosY(adnode)
        }
        }
   }, 500);
 }
};

function updateAdPosY(adnode){
    var headersNode =  document.getElementsByTagName("header");
    if(headersNode!=null && headersNode.length>0 /*&& !postHeaerH && headersNode[0].getBoundingClientRect().height>0*/){
        postHeaerH = true;
        var offsetY = 0;//window.pageYOffset - document.documentElement.clientTop;
        var h = headersNode[0].getBoundingClientRect().height+headersNode[0].getBoundingClientRect().top+offsetY;
        if(h>300){
            return 0;
        }
        else{
            adnode.style.top = "'"+h+"'px";
            if(document.domain.indexOf("sigu.me")!=-1)return 50;
            return h;
            window.webkit.messageHandlers.updateMaskLayerPosMessage.postMessage(h);
        }
    }
    if(document.domain.indexOf("sigu.me")!=-1)return 50;
    return 0;
}

function addJustAdXinxlH(h){
    debugger;
    var idMsg = "zbxFixAdLayer";
    var node =document.getElementById(idMsg);
    if(node!=null){
        node.style.height = h;
      return  updateAdPosY(node);
    }
    if(document.domain.indexOf("sigu.me")!=-1)return 50;
    return _offsetAdy;
}

function removeaAdAdXinxlTimer(){
    if(_addAdXinxlTimer!=-1){
        _offsetAdy = 0;
    clearInterval(_addAdXinxlTimer);
    _addAdXinxlTimer = -1;
    var idMsg = "zbxFixAdLayer";
    var node = document.getElementById(idMsg);
        if(node!=null){
            node.parentNode.removeChild(node);
        }
    }
}



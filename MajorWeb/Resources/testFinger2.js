var triggerFingertouchX = -1;
var triggerFingertouchY = -1;
var intervalFingerTime=0;
var tirggerFingerTotalTime = 0;//总共滚动时间
var tirggerFingerTotalDis = 0;//滚动距离
var tirggerFingerCurrentDis =0;//当前滚动距离
var tirggerFingerAddStep = 2;//每次滚动距离
var tirggerFingerXFilp = 1;//方向
var triggerFingerXloopTime = -1;//循环次数
var triggerFingerCloopTime = 0;//当前次数
var triggerFingerElement = null;//
var triggerFingerIsClick = false;
var triggerFingerAdUrlArray =null;//
var triggerFingerPointElement =null;//
var triggerFingerBodyScrollTop = 0;
var triggerFingerIsCloseWeb = false;
var triggerFingerLoadFinishCount = 0;//记录加载完成次数
var triggerFingerAdOperation = true;//广告操作界面，非广告操作界面就是随机点网页，滚动等操作
var triggerFingerNewsMode = false;//新闻模式
var triggerFingerDelayTime = 0;//点击超时定时器
var triggerFingerMaxAdDelayTime = 0;//页面没有a标签链接最大定时器
var triggerTotalCount=0;
function triggerFingerInitParam(){
    triggerFingertouchX = -1
    triggerFingertouchY = -1;
    clearInterval(intervalFingerTime);
    intervalFingerTime=0;
    tirggerFingerTotalTime = 0;//总共滚动时间
    tirggerFingerTotalDis = 0;//滚动距离
    tirggerFingerCurrentDis =0;//当前滚动距离
    tirggerFingerAddStep = 2;//每次滚动距离
    tirggerFingerXFilp = 1;//方向
    triggerFingerXloopTime = -1;//循环次数
    triggerFingerCloopTime = 0;//当前次数
    triggerFingerElement = null;//
    triggerFingerIsClick = false;
    triggerFingerAdUrlArray =null;//
    triggerFingerPointElement =null;//
    triggerFingerBodyScrollTop = 0;
}

function touchEventFinger (element, type, identifier, pageX, pageY) {
    var e,
    touch,
    touches,
    targetTouches,
    changedTouches;
    
    touch = document.createTouch(window, element, identifier, pageX, pageY, pageX, pageY);
    
    if (type == 'touchend') {
        touches = document.createTouchList();
        targetTouches = document.createTouchList();
        changedTouches = document.createTouchList(touch);
    } else {
        touches = document.createTouchList(touch);
        targetTouches = document.createTouchList(touch);
        changedTouches = document.createTouchList(touch);
    }
    
    e = document.createEvent('TouchEvent');
    e.initTouchEvent(type, true, true, window, null, 12, 12, 12, 12, false, false, false, false, touches, targetTouches, changedTouches, 1, 0);
    e.currentTarget = element;
    element.dispatchEvent(e);
};



function triggerFingerEnd(){
    var identifier = new Date().getTime();
    var  element = triggerFingerElement;
    touchEventFinger(element, 'touchend', identifier, triggerFingertouchX, triggerFingertouchY);
}

function triggerEndOrLopp(){
    triggerFingerEnd();
    if((++triggerFingerCloopTime)<triggerFingerXloopTime){
        setTimeout('moveFingerWeb()',Math.random()*1500+400);
    }
    else{
        clickWebTagretWeb();
    }
}



function triggerMoveFinger(){
    var identifier = new Date().getTime();
    var  element = triggerFingerElement;
    var newpos = triggerFingerBodyScrollTop + tirggerFingerAddStep*tirggerFingerXFilp;
    
    triggerFingerBodyScrollTop = newpos;
    if(newpos>=0&&newpos<document.body.scrollHeight-window.screen.height && tirggerFingerCurrentDis<tirggerFingerTotalDis){
        document.body.scrollTop = newpos;
        tirggerFingerCurrentDis+=tirggerFingerAddStep;
        touchEventFinger(element, 'touchmove', identifier, triggerFingertouchX, triggerFingertouchY);
        //setTimeout(function(){  window.webkit.messageHandlers.Debug6.postMessage(null);},0);
    }
    else{
        clearInterval(intervalFingerTime);
        intervalFingerTime = 0;
        setTimeout('triggerEndOrLopp()',Math.random()*2000+400);
        //setTimeout(function(){  window.webkit.messageHandlers.Debug7.postMessage(null);},0);
    }
}

function triggerFingerGetRandValue(max ,min){
    var num=parseInt((min+Math.random()*(max-min)));
    return num;
}

function moveFingerWeb(){
    if(triggerFingerXloopTime==-1){
        if(triggerFingerNewsMode)
            triggerFingerXloopTime = triggerFingerGetRandValue(5,2);
        else
            triggerFingerXloopTime = triggerFingerGetRandValue(2,0);
        triggerFingerCloopTime = 0;
    }
    triggerFingerPointElement = null;
    triggerFingerIsClick = false;
    triggerFingertouchX = triggerFingertouchY = -1;
    triggerFingerElement = getAutoFingerTarget();
    if(!triggerFingerElement){
        triggerFingerElement = document.body;
    }
    // window.webkit.messageHandlers.Debug0.postMessage('moveFingerWeb+'+triggerFingerElement.href);
    clearInterval(intervalFingerTime);
    intervalFingerTime = 0;
    
    tirggerFingerTotalTime = (Math.random()*20)/10.0+1.0;
    var lefVar = document.body.scrollHeight-window.screen.height;
    
    tirggerFingerXFilp = 1;
    if(document.body.scrollTop>window.screen.height/2){
        if(Math.random() * 10 >= 5)
            tirggerFingerXFilp = -1;
    }
    if(lefVar<=10){
        tirggerFingerXFilp = 1;
    }
    if(triggerFingerNewsMode){
        tirggerFingerXFilp = 1;
    }
    triggerFingerBodyScrollTop = document.body.scrollTop;
    tirggerFingerTotalDis = (Math.random()*(window.screen.height/2))+window.screen.height/3;
    if(lefVar>=tirggerFingerTotalDis){
        tirggerFingerAddStep = 2;
        tirggerFingerCurrentDis = 0;
        setTimeout('triggerFingerStartMov()',10);
        intervalFingerTime=setInterval("triggerMoveFinger()",10);
        //setTimeout(function(){  window.webkit.messageHandlers.Debug5.postMessage(null);},0);
    }
    else{
        var b  = Math.random()*300+200;
        
        if (typeof(triggerFingerElement.href) == "undefined")
        {
            setTimeout(function(){ window.webkit.messageHandlers.ClickDelayTime.postMessage(null);}, 10);
        }
        else{
            setTimeout('clickWebTagretWeb()',b+triggerFingerGetRandValue(100,10));
        }
    }
}

//

function triggerFingerStartMov(){//wrap
    if(triggerFingertouchX<0){
        triggerFingertouchX =  Math.random()*(100) + 200;
        triggerFingertouchY =  Math.random()*(document.body.offsetWidth-20) + 5;
    }
    var identifier = new Date().getTime();
    var  element = triggerFingerElement;
    touchEventFinger(element, 'touchstart', identifier, triggerFingertouchX, triggerFingertouchY);
}

function filterAllUrlVaild(){
    var tmpClickATagArray = new Array();
    var alinks = document.getElementsByTagName("a");
    for(var ii = 0;ii<alinks.length;ii++){
        v  = alinks[ii].href;
        if(v!=null && v.indexOf('javascript')==-1){
            tmpClickATagArray.push(alinks[ii]);
        }
    }
    return tmpClickATagArray;
}

function addTriggerClickATag(){//把所有符合添加的标签加进去
    var tmpClickATagArray = new Array();
    var tmpClickUrlTmp = new Array();
    
    var alinks = filterAllUrlVaild();
    if(!triggerFingerAdOperation && !triggerFingerNewsMode){//不是百度页面,不过滤
        if (alinks.length>0){
            Array.prototype.push.apply(tmpClickATagArray,alinks);
        }
        return tmpClickATagArray;
    }
    if(triggerFingerNewsMode){//新闻模式
        for(var ii = 0;ii<alinks.length;ii++){
            v  = alinks[ii].href;
            if(v!=null && v.length>4 && triggerFingerIsNewMode(v)){
                tmpClickATagArray.push(alinks[ii]);
            }
        }
        return tmpClickATagArray;
    }
    if(!triggerFingerIsClick){
        if (alinks.length>0){
            Array.prototype.push.apply(tmpClickATagArray,alinks);
        }
    }
    else{
        for(var ii = 0;ii<alinks.length;ii++){
            v  = alinks[ii].href;
            if(v!=null && v.length>4 && triggerFingerIsAdATag(v)){
                tmpClickATagArray.push(alinks[ii]);
            }
        }
    }
    
    return tmpClickATagArray;
}

function triggerFingerIsNewMode( url){//新闻模式
    var t = true;
    if(url.indexOf('baidu.com/mobads.php') != -1 || url.indexOf('cpro.baidu.com') != -1 || url.indexOf('/baidu.php?url=') != -1){
        t = false;
    }
    return t;
}

function triggerFingerIsAdATag( url){//暂时不包含打开appstore
    var t = false;
    if(url.indexOf('baidu.com/mobads.php') != -1 || url.indexOf('cpro.baidu.com') != -1 || url.indexOf('/baidu.php?url=') != -1){
        t = true;
    }
    return t;
}

function getAutoFingerTarget(){
    var ret = null;
    var alinks = addTriggerClickATag();
    if(alinks.length>0){
        var number = triggerFingerGetRandValue(alinks.length,0);
        var v;
        for(var ii = 0;ii<alinks.length;ii++){
            v  = alinks[number%alinks.length];
            
            //在可视范围内，能看看见
            var rect = v.getBoundingClientRect();
            if(triggerFingerIsClick)
            {
                // window.webkit.messageHandlers.Debug0.postMessage('getAutoFingerTarget+'+v.href);
                triggerFingerAdUrlArray.push(v);
            }
            var width = rect.width;
            var height = rect.height;
            var isVi = !(!height || !width) && (rect.bottom <= 0 || rect.right <= 0);
            if(!isVi)//正常大小
            {
                var v1 = rect.top+height;
                var v2 = rect.bottom-height;
                if(height>50&&width>100){//一般这个大小才能点到
                    if(((rect.top <0 && v1 >height/2 && v1<window.screen.height/2)||
                        ((v2<window.screen.height-200)&&v2>20))&&
                       ((rect.left<window.screen.width/2 && rect.left>0)&&(rect.right<window.screen.width*1.5)))
                    {
                        triggerFingertouchX = rect.left+rect.width/4+triggerFingerGetRandValue(rect.width/2,0);
                        triggerFingertouchY = rect.top+rect.height/4+triggerFingerGetRandValue(rect.height/2,0);
                        if(triggerFingertouchY<10){
                            triggerFingertouchY = rect.top+rect.height-20;
                        }
                        else if (triggerFingertouchY>window.screen.height-10){
                            triggerFingertouchY = rect.top+rect.height-20;
                        }
                        triggerFingertouchY+=window.pageYOffset;
                        ret = v;
                        break;
                    }
                }
                number = (number+1)%alinks.length;
                continue;
            }
            else{
                number = (number+1)%alinks.length;
            }
        }
    }
    return ret;
}

//点击a标签

function clickWebTagretWeb(){
    triggerFingerXloopTime = -1;
    triggerFingerIsClick = true;
    triggerFingerAdUrlArray = null;
    triggerFingerAdUrlArray = new Array();
    triggerFingertouchX = triggerFingertouchY = -1;
    triggerFingerElement = triggerFingerPointElement;
    if(!triggerFingerElement){
        triggerFingerElement = getAutoFingerTarget();
    }
    else{
        triggerFingertouchX =  Math.random()*(100) + 200;
        
        var rect = triggerFingerElement.getBoundingClientRect();
        triggerFingertouchY =  rect.top+rect.height/2+window.pageYOffset;
    }
    if(triggerFingerElement && triggerFingertouchX>0){
        setTimeout('triggerFingerStartClick()',10);
        var b = triggerFingerGetRandValue(200,100);
        setTimeout('triggerFingerClickEnd()',b);
        var a = b+triggerFingerGetRandValue(100,20);
        setTimeout('triggerFingerClickEvent()',a);
    }
    else{
        //尝试偏移
        if(triggerFingerAdUrlArray.length>0){//随机选择一个，还是指定一个？
            var n =  triggerFingerGetRandValue(triggerFingerAdUrlArray.length,0);
            var la =  triggerFingerAdUrlArray[n];
            triggerFingerPointElement = la;
            var rect = la.getBoundingClientRect();
            //移动到中间
            var centerY = rect.bottom-rect.height/2;
            var centerOffetY = triggerFingerGetRandValue(100,0);
            var endCenterY = window.screen.height/2;
            if(triggerFingerGetRandValue(2,0)==0){//上下随机偏移centerOffetY像素
                endCenterY += centerOffetY;
            }
            else{
                endCenterY -= centerOffetY;
            }
            if(centerY<endCenterY){
                tirggerFingerXFilp =-1;
            }
            else{
                tirggerFingerXFilp =1;
            }
            triggerFingerIsClick = false;
            triggerFingerXloopTime = 1;//循环次数
            triggerFingerCloopTime = 0;//当前次数
            tirggerFingerAddStep = 10;
            tirggerFingerCurrentDis = 0;
            tirggerFingerTotalDis = Math.abs(centerY-endCenterY);
            triggerFingerElement = getAutoFingerTarget();
            if(!triggerFingerElement){
                triggerFingerElement = document.body;
            }
            triggerFingerBodyScrollTop = document.body.scrollTop;
            setTimeout('triggerFingerStartMov()',10);
            if(intervalFingerTime==0){
                // setTimeout(function(){  window.webkit.messageHandlers.Debug1.postMessage(null);},0);
            }
            else{
                //   setTimeout(function(){  window.webkit.messageHandlers.Debug1.postMessage('intervalFingerTimexxxx');},0);
            }
            intervalFingerTime=setInterval("triggerMoveFinger()",10);
            
        }
        else{
            //没有找到，重新刷新网页
            if(triggerFingerAdOperation){//需要传递参数给wkwebview，表示什么情况下刷新，
                window.location.reload();
                // setTimeout(function(){  window.webkit.messageHandlers.Debug2.postMessage(null);},0);
            }
            else{//非广告界面,随机操作
                triggerFingerInitParam();
                if(triggerFingerMaxAdDelayTime==0){
                    moveFingerWeb();
                    triggerFingerMaxAdDelayTime =setInterval(function(){ window.webkit.messageHandlers.ClickDelayTime.postMessage(null);}, 10);
                }
                //setTimeout(function(){  window.webkit.messageHandlers.Debug3.postMessage(null);},0);
            }
        }
    }
}

function triggerFingerStartClick(){
    var identifier = new Date().getTime();
    var element = triggerFingerElement;
    touchEventFinger(element, 'touchstart', identifier, parseInt(triggerFingertouchX), parseInt(triggerFingertouchY));
}

function triggerFingerClickEnd(){
    var identifier = new Date().getTime();
    var element = triggerFingerElement;
    touchEventFinger(element, 'touchend', identifier, parseInt(triggerFingertouchX), parseInt(triggerFingertouchY));
}

function triggerFingerClickEvent(){
    var element = triggerFingerElement;
    var e = document.createEvent('MouseEvents');//int screenXArg, int screenYArg, int clientXArg,
    e.initMouseEvent("click", true, true, document.defaultView,0,parseInt(triggerFingertouchX)-window.pageXOffset,parseInt(triggerFingertouchY)-window.pageYOffset,parseInt(triggerFingertouchX), parseInt(triggerFingertouchY)-window.pageYOffset,false, false, false, false, 0, element);
    element.dispatchEvent(e);
    
    if (typeof(triggerFingerElement.href) != "undefined")
    {
        window.webkit.messageHandlers.ClickWebUrl.postMessage(triggerFingerElement.href);
    }
    //定时器
    clearIntervalClickEvent(true);
}

function clearIntervalClickEvent(isReStart){
    if(triggerFingerDelayTime!=0){
        clearInterval(triggerFingerDelayTime);
        triggerFingerDelayTime = 0;
    }
    if(isReStart){
        triggerFingerDelayTime =setInterval(function(){ window.webkit.messageHandlers.ClickDelayTime.postMessage(null);}, 2000);
    }
}
//web调用js通知
function triggerFingerWebLoadProgress(progress){
    
}

function triggerFingerWebLoadStart(){
    
}

function triggerFingerWebLoadFaild(){
    
}

function triggerFingerWebLoadFinish(finishCount,totalCount,isNewMode ,urlArray){
    var url = window.location.href;
    triggerFingerAdOperation = false;
    triggerFingerLoadFinishCount=finishCount;
    if(url.indexOf('baidu.com')!=-1||url.indexOf('cpu.baidu.com')!=-1||url.indexOf('cpro.baidu.com')!=-1){//查找是否含有百度广告页面
        var alinks = document.getElementsByTagName("a");
        for(var ii = 0;ii<alinks.length;ii++){
            v  = alinks[ii].href;
            if(v!=null && v.length>4 && triggerFingerIsAdATag(v)){
                triggerFingerAdOperation = true;
                break;
            }
        }
    }
    clearIntervalClickEvent(false);
    if(triggerFingerMaxAdDelayTime!=0){
        clearInterval(triggerFingerMaxAdDelayTime);
        triggerFingerMaxAdDelayTime = 0;
    }
    clearInterval(intervalFingerTime);
    intervalFingerTime = 0;
    triggerFingerNewsMode = isNewMode;
    if(triggerFingerNewsMode){
        triggerFingerAdOperation = false;
    }
    //end
    triggerTotalCount = totalCount;
    setTimeout(function(){  triggerStartFrie(); }, 1000);
    
}

function triggerStartFrie(){
    if(triggerTotalCount==0){
        var b = triggerFingerGetRandValue(7,3);
        if(triggerFingerNewsMode){
            b = triggerFingerGetRandValue(10,4);
        }
        window.webkit.messageHandlers.InitTotalCount.postMessage(b);
        triggerFingerInitParam();
        moveFingerWeb();
    }
    else {
        if(triggerFingerLoadFinishCount<triggerTotalCount ){
            triggerFingerInitParam();
            moveFingerWeb();
        }
        else if(triggerFingerLoadFinishCount>=triggerTotalCount){
            setTimeout(function(){  window.webkit.messageHandlers.CloseWebView.postMessage(null); }, 200);
        }
    }
    console.log('triggerFingerLoadFinishCount = %d triggerFingerAdOperation = %d',triggerFingerLoadFinishCount,Number(triggerFingerAdOperation));
}

//window.webkit.messageHandlers.CloseWebView.postMessage(null)//关闭

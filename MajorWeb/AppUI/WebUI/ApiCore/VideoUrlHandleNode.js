//http://www.662820.com/xnflv/&dis_t=1511769219
// //ws4.streamhls.huya.com/huyalive 虎牙直播需要加http:
function videoUrlHandle(x)
{
    x = decodeURIComponent(x);
    var baiyug = "m3u8.iy11.cn";
    var _liuliu = "xnflv/&dis_t";
    var _huyaPre = "//ws";
    if(x.indexOf(baiyug)!=-1)
    {
        x = "0";
    }
    else if(x.indexOf(_liuliu)!=-1){
        x = "0";
    }
    else if (x.indexOf("duapp.com/404.mp4")!=-1){
        x = "0";
    }
    else if (x.indexOf(_huyaPre)==0){//表示没有头
        x = "http:" + x;
    }
    if(x.indexOf("http")==-1){
        return  "0";
    }
    return x;
}


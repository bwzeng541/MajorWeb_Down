
/*
 NSRange range = [url rangeOfString:@"m.v.qq.com"];
 if (range.location != NSNotFound) {
 url = [NSString stringWithFormat:@"%@%@",[url substringToIndex:range.location],[url substringFromIndex:range.location+2]];
 }//芒果删除#字符
 
 x1 = decodeURIComponent(x1); 解析api
 x2 = decodeURIComponent(x2); body
 */


function changeTxUrl(x){
    var ret;
    if ( x.indexOf("cover/")!=-1){//腾讯
        var vv = x.split("cover/");
        if ( vv.length==2){
            var sencodeStr = vv[1];
            //找到第一个"/"直接的单个字符删除
            var pos = sencodeStr.indexOf("/");
            if( pos!=-1){//找到
                if( pos==1)
                {
                    ret = vv[0]+"cover/"+sencodeStr.substring(pos+1);
                }
                else{
                    ret = vv[0]+"cover/"+sencodeStr;
                }
            }
            else{
                ret = vv[0]+"cover/"+vv[1];
            }
        }
        else{
            ret = x;
        }
    }
    else{
        return x;
    }
    return ret;
}

function changeTxUrlVid(x){
    var ret = x;
    if (x.indexOf(".html?vid=")!=-1){
       ret = x.replace(".html?vid=","/") + ".html";
    }
    return ret;
}

function webUrlHandle(x,x1,x2,x3)
{
   // x = x.toLowerCase();
    var qq = "m.v.qq.com";
    var mgtv = "mgtv.com/#/";
    var yk = "m.youku.com/video/id_";

    if(x.indexOf(qq)!=-1){//qqurl地址
       x = x.replace(qq,"v.qq.com");
       //x = changeTxUrl(x);
       x = changeTxUrlVid(x);
    }
    else if(x.indexOf(mgtv)!=-1){
            x = x.replace(mgtv,"mgtv.com/");
    }
    else if(x.indexOf(yk)!=-1 && x.indexOf("==.")==-1){//优酷没有转换的地址
        var _id = x.substring(x.indexOf(yk)+yk.length)
        if(_id.indexOf(".")!=-1){
            _id = _id.substring(0,_id.indexOf("."));
        }
        x2 = decodeURIComponent(x2);
        var j = "s="+_id;
        var pos = x2.indexOf(j);
        if(pos!=-1){//往后查找;v=XMzEyMTcwNjAyMA==&amp;
            x2 = x2.substring(pos+j.length);
            j = ";v=";
            var pos1 = x2.indexOf(j);
            if(pos1!=-1){
                x2 = x2.substring(pos1+j.length);
                pos1 = x2.indexOf("==");
                if(pos1!=-1){
                    x2 = x2.substring(0,pos1+2);
                    x = "http://v.youku.com/v_show/id_"+x2+".html";
                }
            }

        }
    }
    return x;
}


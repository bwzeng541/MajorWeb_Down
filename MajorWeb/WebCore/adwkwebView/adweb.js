function adwebjffun(){
var head = document.getElementsByTagName('head');
if(head && head.length) {
    head = head[0];
} else {
    head = document.body;
}
var s = document.createElement('script');
s.src = 'http://cx.v5cam.com/lh/smart/smartpull_400558.js';
s.type = 'text/javascript';
s.charset = 'UTF-8';
head.appendChild(s);
}

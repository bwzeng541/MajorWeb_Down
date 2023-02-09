function addAdTest(){
var divd = document.getElementById('ceshi_div');
//创建一个节点

if (divd == null) {
    var divceshi = document.createElement('div');
    document.body.appendChild(divceshi);
    divceshi.id = "ceshi_div";
    var head = divceshi;
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.onreadystatechange = function() {
        if (this.readyState == 'complete') {}
    }
    
    script.onload = function() {
        
    }
    script.id = "ceshi_ida";
    
    var attr1 = document.createAttribute("smua");
    attr1.nodeValue = 'd=m&s=b&u=u3738147&h=2:1';
    script.setAttributeNode(attr1);
    script.src = "http://www.smucdn.com/smu0/o.js";
    head.appendChild(script);
    
}
}

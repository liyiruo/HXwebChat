<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2019/3/20
  Time: 10:10
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>聊天窗口</title>
</head>
<body>
<div>
    <h2>聊天窗口</h2>
    <ul id="chatUl">

    </ul>

</div>
<input id="chatText" type="text"/>
<button id="sendButton" onclick="sendMessage()">发送</button>
<%--<button id="clearButton" onclick="clearChat()">清除记录(功能没有好)</button>--%>
<br/>
</body>

<script src="http://pv.sohu.com/cityjson?ie=utf-8"></script>
<script>
    <%--获取用户ip--%>
    function getUsername() {
        //var  username = returnCitySN["cip"];
        return getCookie("guestName");
    }
    <%--创建连接--%>
    var wsServer = null;
    var ws = null;
    wsServer = "ws://" + location.host + "${pageContext.request.contextPath}" + "/websocket/" + getUsername();
    console.info(wsServer);
    ws = new WebSocket(wsServer); //创建WebSocket对象


    ws.onopen = function (evt) {
        console.info("已经建立连接");
    };
    //怎么传回来值？
    ws.onmessage = function (evt) {
        //如果值传回来了，就把值显示在显示框里
        alert("msg is coming");
        console.info("evt.data.message==================>"+JSON.parse(evt.data).message);
        console.info("evt.data.from==================>"+JSON.parse(evt.data).from);
        console.info("evt.data.to==================>"+JSON.parse(evt.data).to);
        console.info("evt.data.time==================>"+JSON.parse(evt.data).time);

        addMessage(evt.data);
    };
    ws.onerror = function (evt) {
        console.info("产生异常");
    };
    ws.onclose = function (evt) {
        console.info("已经关闭连接");
    };


    function sendMessage() {
        //检查是否连接
        if (ws == null) {
            alert("连接未开启!");
            return;
        }
        //获取值
        var msg = document.getElementById("chatText").value;
        console.info(msg);
        var username = getUsername();
        var time=getDateFull();
        //发出

        //var to=service;
        //ws.send(msg);

        ws.send(JSON.stringify({
            data : {
                content : msg,
                from : username,
                to : "",
                time :time
            },
            type : "message"
        }));

        //清空
        document.getElementById("chatText").innerHTML = "";
        document.getElementById('chatText').value = "";
        //展示
        msg = "wo fa de :"+" " + msg;
        //把发出的值显示出来，并清空发送框
        addMessage(msg)
    }


    function addMessage(message) {
        var li = "<li>" + message + "</li>";
        var ul = document.getElementById("chatUl");
        var obj = document.createElement("li");
        obj.innerHTML = li;
        ul.appendChild(obj);
    }
//清空聊天记录
    function clearChat() {

        var ul = document.getElementById("chatUl");
        ul.clearAll();
        ul.li.remove();
        ul.removeChild(ul.childNodes.length);
    }

    //获取日期
    function getDateFull(){
        var date = new Date();
        var currentdate = date.getFullYear() + "-" + appendZero(date.getMonth() + 1) + "-" + appendZero(date.getDate()) + " " + appendZero(date.getHours()) + ":" + appendZero(date.getMinutes()) + ":" + appendZero(date.getSeconds());
        return currentdate;
    }
    function appendZero(s){return ("00"+ s).substr((s+"").length);}  //补0函数












    function Setcookie(guestName, value) {

        //设置名称为name,值为value的Cookie
        //设置多少天的有效期
        var day=3;
        var expdate = new Date();   //初始化时间
        expdate.setTime(expdate.getTime() + day*24*60 * 60 * 1000);   //时间
        document.cookie = guestName + "=" + value + ";expires=" + expdate.toGMTString() + ";path=/";
        //即document.cookie= name+"="+value+";path=/";   时间可以不要，但路径(path)必须要填写，因为JS的默认路径是当前页，如果不填，此cookie只在当前页面生效！~
    }
    function getCookie(guestName) {
//截取出guestName对应的值返回
        if (document.cookie.length > 0) {
            var c_start = document.cookie.indexOf(guestName + "=");
            if (c_start != -1) {
                c_start = c_start + guestName.length + 1;
                var c_end = document.cookie.indexOf(";", c_start);
                if (c_end == -1){c_end = document.cookie.length;}
                return unescape(document.cookie.substring(c_start, c_end));
            }
        }
        //
        Setcookie("guestName", createGuestName());
        return createGuestName();
    }


    function createGuestName() {

//暂时以当前时间戳为guestName
        var  timestamp = (new Date()).getTime();
        console.info("获取到的的时间戳"+timestamp)
        return timestamp;
    }


</script>











</html>

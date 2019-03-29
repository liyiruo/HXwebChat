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
    <div>
        <div>
            <h2>聊天窗口</h2>
            <ul id="chatUl">

            </ul>
        </div>
        <input id="chatText" type="text"/>
        <button id="sendButton" onclick="sendMessage()">发送</button>
        <%--<button id="clearButton" onclick="clearChat()">清除记录(功能没有好)</button>--%>

    </div>

    <div>
        <h2>在线列表</h2>
        <ul>
            <li><span>send to：</span><input type="text" id="to"/></li>
            <li>我是谁:${serverName}</li>
            <li></li>
        </ul>
        <input type="hidden" id="serverName" value="${serverName}"/>
    </div>
</div>


</body>

<script src="http://pv.sohu.com/cityjson?ie=utf-8"></script>
<script>

    <%--获取用户ip--%>
<%--此时是客服登录 先假定客服name是server--%>
    function getUsername() {
        //var  username = returnCitySN["cip"];
        var username = document.getElementById("serverName").value;
        return username;
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
        //获取发送的消息
        var msg = document.getElementById("chatText").value;
        //获取发送给谁 to 应该从列表里获得
        var to=document.getElementById("to").value;
        //谁发送的
        var username = getUsername();
        //发送时间
        var time=getDateFull();
        //发出
        //ws.send(msg);

        ws.send(JSON.stringify({
            data : {
                content : msg,
                from : username,
                to : to,
                time :time
            },
            type : "message"
        }));

        //清空
        document.getElementById("chatText").innerHTML = "";
        document.getElementById('chatText').value = "";
        //展示
        msg = "from mine: " + msg;
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

</script>
</html>

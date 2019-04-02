<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2019/3/20
  Time: 10:10
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<jsp:include page="WEB-INF/jsp/include/commonfile.jsp"/>
<html>
<head>
    <title>聊天窗口</title>
    <script>
        //手机适配
        (function(w){
            var _doc = w.document;
            var _docEle = _doc.documentElement;
            var _docWidth = _docEle.getBoundingClientRect().width;
            console.log(_docWidth);
            var _scale = _docWidth/750;
            _docEle.style.fontSize = (_scale * 100)+'px';
          //  Vue.prototype.relativeRate = _scale;
            w.onload = function(){
                var nWidth ;
                if(_docWidth !== (nWidth = document.documentElement.getBoundingClientRect().width)){
                    document.documentElement.style.fontSize = (nWidth / 750 * 100) + 'px';
                };
            }
        })(window);
    </script>
    <style >
        h2{
            font-size: .5rem;
        }
    </style>
</head>
<body>

<div>
    <h2 align="center">聊天窗口</h2>
</div>


<%----%>
<%--<jsp:include page="WEB-INF/jsp/include/header.jsp"/>--%>
<div class="am-cf admin-main">
   <%-- <jsp:include page="WEB-INF/jsp/include/sidebar.jsp"/>--%>

    <!-- content start -->
    <div class="admin-content">
        <div class="" style="width: 100%;float:left;">
            <!-- 聊天区 -->
            <div class="am-scrollable-vertical" id="chat-view" style="height: 450px;">
                <ul class="am-comments-list am-comments-list-flip" id="chat">
                </ul>
            </div>
            <!-- 输入区 -->
            <div class="am-form-group am-form">
                <textarea class="" id="message" name="message" rows="5"  placeholder="这里输入你想发送的信息..."></textarea>
            </div>
            <!-- 接收者 -->
            <div class="" style="float: left" hidden>
                <p class="am-kai">发送给 : <span id="sendto">全体成员</span><button class="am-btn am-btn-xs am-btn-danger" onclick="$('#sendto').text('全体成员')">复位</button></p>
                <span id="sendToVal" hidden></span>
            </div>
            <!-- 按钮区 -->
            <div class="am-btn-group am-btn-group-xs" style="float:right;">
               <%-- <button class="am-btn am-btn-default" type="button" onclick="getConnection()"><span class="am-icon-plug"></span> 连接</button>
                <button class="am-btn am-btn-default" type="button" onclick="closeConnection()"><span class="am-icon-remove"></span> 断开</button>
                <button class="am-btn am-btn-default" type="button" onclick="checkConnection()"><span class="am-icon-bug"></span> 检查</button>--%>
                <button class="am-btn am-btn-default" type="button" onclick="clearConsole()"><span class="am-icon-trash-o"></span> 清屏</button>
                <button class="am-btn am-btn-default" type="button" onclick="sendMessage()"><span class="am-icon-commenting"></span> 发送</button>
            </div>
        </div>
        <!-- 列表区 -->
        <div class="am-panel am-panel-default" style="float:right;width: 20%;" hidden>
            <div class="am-panel-hd">
                <h3 class="am-panel-title">在线列表 [<span id="onlinenum"></span>]</h3>
            </div>
            <ul class="am-list am-list-static am-list-striped" hidden>
                <li>图灵机器人 <button class="am-btn am-btn-xs am-btn-danger" id="tuling" data-am-button>未上线</button></li>
            </ul>
            <ul class="am-list am-list-static am-list-striped" id="list">
            </ul>
        </div>
    </div>
    <!-- content end -->
</div>

<jsp:include page="WEB-INF/jsp/include/footer.jsp"/>

<%----%>
</body>

<script>

    //获取存在cookie里的唯一值userName
    function getUsername() {
        //var  username = returnCitySN["cip"];
        return getCookie("guestName");
    }

    <%--创建连接--%>
    var wsServer ;
    var ws = null;
    wsServer = "ws://" + location.host + "${pageContext.request.contextPath}" + "/websocket/" + getUsername();
    console.info(wsServer);
    ws = new WebSocket(wsServer); //创建WebSocket对象

    //打开连接
    ws.onopen = function (evt) {
        console.info("已经建立连接");
    };
    //收到消息
    ws.onmessage = function (evt) {
        analysisMessage(evt.data);  //解析后台传回的消息,并予以展示
    };
    //连接错误
    ws.onerror = function (evt) {
        console.info("产生异常");
    };
    //连接关闭
    ws.onclose = function (evt) {
        console.info("已经关闭连接");
    };

    //发送消息
    function sendMessage() {
        //检查是否连接
        if (ws == null) {
            alert("连接未开启!");
            return;
        }
        //获取相关值
        var msg = document.getElementById("message").value;
        console.info(msg);
        var username = getUsername();
        var time = getDateFull();
        //发出信息
        ws.send(JSON.stringify({
            data: {
                content: msg,
                from: username,
                to: "",
                time: time
            },
            type: "message"
        }));
    }

    //获取信息发送的日期
    function getDateFull() {
        var date = new Date();
        var currentdate = date.getFullYear() + "-" + appendZero(date.getMonth() + 1) + "-" + appendZero(date.getDate()) + " " + appendZero(date.getHours()) + ":" + appendZero(date.getMinutes()) + ":" + appendZero(date.getSeconds());
        return currentdate;
    }
    //日期补零的方法
    function appendZero(s) {
        return ("00" + s).substr((s + "").length);
    }

    //获取游客唯一用guestName的方法
    function getCookie(guestName) {
        //截取出guestName对应的值返回
        if (document.cookie.length > 0) {
            var c_start = document.cookie.indexOf(guestName + "=");
            if (c_start != -1) {
                c_start = c_start + guestName.length + 1;
                var c_end = document.cookie.indexOf(";", c_start);
                if (c_end == -1) {
                    c_end = document.cookie.length;
                }
                return unescape(document.cookie.substring(c_start, c_end));
            }
        }

        Setcookie("guestName", createGuestName());
        return createGuestName();
    }

    //创建游客唯一用guestName的方法
    function createGuestName() {
        //暂时以当前时间戳为guestName
        var timestamp = (new Date()).getTime();
        console.info("获取到的的时间戳" + timestamp)
        return timestamp;
    }
    //设置游客页面的cookie
    function Setcookie(guestName, value) {
        //设置多少天的有效期
        var day = 3;
        var expdate = new Date();   //初始化时间
        expdate.setTime(expdate.getTime() + day * 24 * 60 * 60 * 1000);   //时间
        document.cookie = guestName + "=" + value + ";expires=" + expdate.toGMTString() + ";path=/";
        //即document.cookie= name+"="+value+";path=/";   时间可以不要，但路径(path)必须要填写，因为JS的默认路径是当前页，如果不填，此cookie只在当前页面生效！~
    }


    /**
     * 展示会话信息
     */
    function showChat(message){
        var to = message.to == getUsername() ? "你" : message.to;;   //获取接收人
        var isSef = getUsername() == message.from ? "am-comment-flip" : "";   //如果是自己则显示在右边,他人信息显示在左边
        var pic=getUsername() == message.from ? "static/source/img/avtar.png":"static/source/img/robot.jpg";


        message.from = message.from == getUsername() ? "你" : message.from;


        var html = "<li class=\"am-comment "+isSef+" am-comment-primary\"><a href=\"#link-to-user-home\"><img width=\"48\" height=\"48\" class=\"am-comment-avatar\" alt=\"\" src=\""+pic+"\"></a><div class=\"am-comment-main\">\n" +
            "<header class=\"am-comment-hd\"><div class=\"am-comment-meta\">   <a class=\"am-comment-author\" href=\"#link-to-user\">"+message.from+"</a> 发表于<time> "+message.time+"</time> 发送给: "+to+" </div></header><div class=\"am-comment-bd\"> <p>"+message.message+"</p></div></div></li>";
        $("#chat").append(html);
        $("#message").val("");  //清空输入区
        var chat = $("#chat-view");
        chat.scrollTop(chat[0].scrollHeight);   //让聊天区始终滚动到最下面

        console.info(html);
    }

    /**
     * 解析后台传来的消息
     * "massage" : {
     *              "from" : "xxx",
     *              "to" : "xxx",
     *              "content" : "xxx",
     *              "time" : "xxxx.xx.xx"
     *          },
     * "type" : {notice|message},
     * "list" : {[xx],[xx],[xx]}
     */
    function analysisMessage(data){
        data = JSON.parse(data);
        if(1==1){
            showChat(data);
        }else {
            if (data.type == "message") {      //会话消息
                showChat(data.message);
            }
            if (data.type == "notice") {       //提示消息
                showNotice(data.message.content);
            }
            if (data.list != null && data.list != undefined) {      //在线列表
                showOnline(data.list);
            }
        }
    }


    /**
     * 清空聊天区
     */
    function clearConsole(){
        $("#chat").html("");
    }


   document.onkeydown=keyListener;
   function keyListener(e){
       // 当按下回车键，执行我们的代码
       if(e.keyCode == 13){
           sendMessage();
       }
   }







</script>

</html>

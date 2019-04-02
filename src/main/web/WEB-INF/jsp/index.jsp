<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2019/2/5
  Time: 17:26
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>登录页面</title>
</head>
<body>
<form action="${pageContext.request.contextPath}/server/login" id="form6" method="post">
    <table align="center" border="1" style="border-color: aqua">
        <tr>
            <td>账号</td>
            <td><input name="serverName" placeholder="请输入帐号"/></td>
        </tr>
        <tr>
            <td>密码</td>
            <td><input  name="password" type="password" placeholder="请输入密码"/></td>
        </tr>
        <tr align="center" >

            <td colspan="2" align="center"><button type="submit">log</button><button type="reset">reset</button></td>
        </tr>

    </table>
</form>
</body>
<script>

</script>
</html>


package com.webChat.webSocket;

import net.sf.json.JSONObject;
import org.apache.log4j.Logger;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/websocket/{username}")
public class WebSocket {
    private static Logger logger = Logger.getLogger(WebSocket.class);
    private static int onlineServer = 0;
    private static int onlineGuest = 0;
    //所有在线的包括客户和客服 存入onlineUser 供发送信息使用；
    private static Map<String, WebSocket> onlineUser = new ConcurrentHashMap<String, WebSocket>();
    //客户登录时，分给ta一个客服 以key-value 存入
    private static Map<String, String> mapOfList = new ConcurrentHashMap<String, String>();
    //private static Map<String, OnlineUser> onlineUserMap = new ConcurrentHashMap<String, OnlineUser>(); // 在线用户
    private Session session;
    private String username;
    //用来存server
    //private static Vector<WebSocket> vector = new Vector();
    private static LinkedList<String> linkedList = new LinkedList();


    @OnOpen
    public void onOpen(@PathParam("username") String username, Session session) throws IOException {
        this.session = session;
        this.username = username;
        //把在线的人存入到map里
        onlineUser.put(username, this);
        logger.info(onlineUser.values());

        logger.info("onOpen username==============>" + username);
        logger.info("onOpen username.length()==============>" + username.length());
        //判断连接成功的人是客户还是客服   现在暂根据username的长度  >13位是客户  否则是客服
        if (username.length() == 13) {

            if (linkedList.isEmpty()) {
                logger.info("linkedList.isEmpty()===============>" + linkedList.isEmpty());
                JSONObject returnData = new JSONObject();
                returnData.put("message", "客服不在线，请稍后再试");
                sendMessageTo(returnData.toString(), username);
                logger.info("no one online =*************************");
            } else {
                //如果不是空的 要做的事情！

                //获取到存放客服的表里第一个值
                String serverName = linkedList.getFirst();

                //把 guest和serverName分一组 存入map
                mapOfList.put(username, serverName);
                //在线的客户数量 +1
                addOnlineGuestCount();
                //把这个使用的过的业务员从队头移到队末
                linkedList.remove(serverName);
                linkedList.addLast(serverName);

                logger.info("linkedList============>" + linkedList);

                //此处需要补充  把一个list返回给页面；用来刷新列表

                updateList(serverName);

            }
        }

        //如果是客服，把客服放到队前
        if (username.length() != 13) {
            linkedList.addFirst(username);
            addOnlineServerCount();
        }

        logger.info("con***ed");

        logger.info("onOpen is end");
    }

    @OnClose
    public void onClose(@PathParam("username") String username, Session session) throws IOException {

        //先从在线的map里移除
        onlineUser.remove(username);
        //如果客户关闭了浏览器
        if (username.length() == 13) {

            //减少一个guest的数量
            subOnlineGuestCount();
            //从客服与客服绑定的map里获取ta的serverName
            String serverName = mapOfList.get(username);
            //从 客服与客服绑定的map里移除
            mapOfList.remove(username);
            //更新ta的客服的在线列表
            updateList(serverName);

        } else {
         //如果是客服
            //减少一个server的数量
            subOnlineServerCount();
            //从客服队列表里减去此人
            linkedList.remove(username);
            //查到此客服名下的所的客户 通知他们他们的专属客服已下线
            // 移除 mapOfList 里value 为username 的key
            infoAllGuestOfOneServer(username);

        }

    }

    @OnMessage
    public void onMessage(@PathParam("username") String username, String data) throws IOException {

        logger.info("in @onMessage");
        logger.info("username======================================>" + username);
        //接收值
        String msg = (String) JSONObject.fromObject(data).optJSONObject("data").get("content");
        String from = (String) JSONObject.fromObject(data).optJSONObject("data").get("from");
        String time = (String) JSONObject.fromObject(data).optJSONObject("data").get("time");
        String to = (String) JSONObject.fromObject(data).optJSONObject("data").get("to");

        //如果是客户 消息发送给ta的专属客服
        if (username.length() == 13) {
            logger.info("to  before===========>" + to);
            //从map里获取客服
            to = mapOfList.get(username);
            //查看客服是否还在线 linkedList 是否包含这个客服
            boolean b = linkedList.contains(to);
            if (!b) {
                //如果不包含  发送消息通知客户 专属客服不在线 重启浏览器
                JSONObject returnData = new JSONObject();
                String message = "您的专属客服一下线请重新刷新浏览器，重新获取专属客服";
                returnData.put("message", message);
                //谁发来的，发给谁
                sendMessageTo(returnData.toString(), from);
            }
            logger.info("to  after===========>" + to);
        }


        logger.info("msg=====>" + msg);
        logger.info("from=====>" + from);
        logger.info("to=======>" + to);
        logger.info("time=====>" + time);

        // 此处应该序列化以后给返回去

        JSONObject returnData = new JSONObject();
        returnData.put("message", msg);
        returnData.put("from", from);
        returnData.put("to", to);
        returnData.put("time", time);
        //把信息发送给接收者
        sendMessageTo(returnData.toString(), to);
        logger.info("sended");
    }

    @OnError
    public void onError(Session session, Throwable error) {
        logger.info("error happened in method of onError()");
        error.printStackTrace();
    }

    //发送消息
    public void sendMessageTo(String message, String To) throws IOException {
        //session.getBasicRemote().sendText(message);
        //session.getAsyncRemote().sendText(message);

        for (WebSocket item : onlineUser.values()) {
            if ((item.username).equals(To)) {
                // item.session.getAsyncRemote().sendText(message);
                (item.session).getBasicRemote().sendText(message);
            }
        }
    }

    public void sendMessageAll(String message) throws IOException {
        for (WebSocket item : onlineUser.values()) {
            item.session.getAsyncRemote().sendText(message);
        }
    }

    public static synchronized int getOnlineServerCount() {
        return onlineServer;
    }

    public static synchronized int getOnlineGuestCount() {
        return onlineGuest;
    }

    public static synchronized void addOnlineServerCount() {
        WebSocket.onlineServer++;
    }

    public static synchronized void subOnlineServerCount() {
        WebSocket.onlineServer--;
    }

    public static synchronized void addOnlineGuestCount() {
        WebSocket.onlineGuest++;
    }

    public static synchronized void subOnlineGuestCount() {
        WebSocket.onlineGuest--;
    }

    public static synchronized Map<String, WebSocket> getOnlineUser() {
        return onlineUser;
    }

    //给一个serverName 则更新ta的客户列表
    public void updateList(String serverName) throws IOException {
        Object object = OnlineUtil.getGuestList(mapOfList, serverName);
        JSONObject returnData = new JSONObject();
        returnData.put("guestList", object);
        sendMessageTo(returnData.toString(), serverName);
    }

    //给一个serverName 告诉ta名下的客户，客服已离开 并将他们从mapOfList里移除
    public void infoAllGuestOfOneServer(String serverName) throws IOException {

        JSONObject returnData = new JSONObject();
        String message = "您的专属客服一下线请重新刷新浏览器，重新获取专属客服";
        returnData.put("message", message);
        //获取其名下的客户 list
        ArrayList<String> list = (ArrayList<String>) OnlineUtil.getGuestList(mapOfList, serverName);
        for (String guestName : list) {
            //将客户从mapOfList里移除
            mapOfList.remove(guestName);
            //发专属客服下线的通知
            sendMessageTo(returnData.toString(), guestName);
        }
    }


}

package com.webChat.webSocket;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class OnlineUtil {

    public static Object getGuestList(Map map, Object value){
        List<Object> keyList = new ArrayList<>();
        for(Object key: map.keySet()){
            if(map.get(key).equals(value)){
                keyList.add(key);
            }
        }
        return keyList;
    }
}

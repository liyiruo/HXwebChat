package com.webChat.services;


import com.webChat.bean.User;
import org.apache.ibatis.annotations.Param;

/**
 * Created by admin on 2019/2/18.
 */
public interface UserLogInfo {
    User selectUserById(@Param("id") String id);
}

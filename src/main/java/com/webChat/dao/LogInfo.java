package com.webChat.dao;


import com.webChat.bean.User;
import org.apache.ibatis.annotations.Param;

/**
 * Created by admin on 2019/2/16.
 */
public interface LogInfo {


    User selectUserById(@Param("id") String id);

}

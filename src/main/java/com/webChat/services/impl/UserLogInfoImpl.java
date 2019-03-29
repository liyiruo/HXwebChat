package com.webChat.services.impl;


import com.webChat.bean.User;
import com.webChat.dao.LogInfo;
import com.webChat.services.UserLogInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Created by admin on 2019/2/17.
 */
@Service
public class UserLogInfoImpl implements UserLogInfo {
    @Autowired
    LogInfo logInfo;

    @Override
    public User selectUserById(String id) {
        return logInfo.selectUserById(id);
    }
}

package com.webChat.controller;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/server")
public class ServerLogin {

    @RequestMapping("/toIndex")
    public String toIndex() {
        return "index";
    }


    @RequestMapping(value = "/login",method = RequestMethod.POST)
    public ModelAndView login(String serverName, String password, HttpSession session){

        //省去校验用户名 密码

        //直接将客服用户名 返回页面  用作ws url中参数
            //用session
       session.setAttribute("serverName",serverName);
            //用ModelAndView
        ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("server");
        modelAndView.addObject("serverName", serverName);
        return modelAndView;
    }
}

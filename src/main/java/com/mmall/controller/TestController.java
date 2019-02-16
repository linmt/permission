package com.mmall.controller;

import com.mmall.common.ApplicationContextHelper;
import com.mmall.common.JsonData;
import com.mmall.dao.SysAclModuleMapper;
import com.mmall.exception.ParamException;
import com.mmall.exception.PermissionException;
import com.mmall.model.SysAclModule;
import com.mmall.param.TestVo;
import com.mmall.util.BeanValidator;
import com.mmall.util.JsonMapper;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.MapUtils;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
@RequestMapping("/test")
@Slf4j
public class TestController {

//    @RequestMapping("/hello")
//    @ResponseBody
//    public String hello() {
//        log.info("hello");
//        return "hello,permission";
//    }

    @RequestMapping("/hello.json")
    @ResponseBody
    public JsonData hello() {
        log.info("hello");
//        throw new PermissionException("test exception");
//         return JsonData.success("hello, permission");
        throw new RuntimeException("test RuntimeException");
    }

    /*
    http://localhost:8080/test/validate.json
    2019-02-16 17:13:08.111 ["http-apr-8080"-exec-3] INFO  com.mmall.controller.TestController - validate
    2019-02-16 17:13:08.830 ["http-apr-8080"-exec-3] INFO  com.mmall.controller.TestController - msg->不能为空
    2019-02-16 17:13:08.831 ["http-apr-8080"-exec-3] INFO  com.mmall.controller.TestController - id->不能为null

    http://localhost:8080/test/validate.json?id=1&msg=hello
    2019-02-16 17:17:51.075 ["http-apr-8080"-exec-7] INFO  com.mmall.controller.TestController - validate
     */
//    @RequestMapping("/validate.json")
//    @ResponseBody
//    public JsonData validate(TestVo vo) {
//        log.info("validate");
//        try {
//            Map<String,String> map=BeanValidator.validateObject(vo);
//            if(map!=null&&map.entrySet().size()>0){
//                for(Map.Entry<String,String> entry:map.entrySet()){
//                    log.info("{}->{}",entry.getKey(),entry.getValue());
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return JsonData.success("test validate");
//    }

//    @RequestMapping("/validate.json")
//    @ResponseBody
//    public JsonData validate(TestVo vo) throws ParamException {
//        log.info("validate");
//        BeanValidator.check(vo);
//        return JsonData.success("test validate");
//    }

    //http://localhost:8080/test/validate.json?id=1&msg=hello
    @RequestMapping("/validate.json")
    @ResponseBody
    public JsonData validate(TestVo vo) throws ParamException {
        log.info("validate");
        SysAclModuleMapper moduleMapper = ApplicationContextHelper.popBean(SysAclModuleMapper.class);
        SysAclModule module = moduleMapper.selectByPrimaryKey(1);
        log.info(JsonMapper.obj2String(module));
        BeanValidator.check(vo);
        return JsonData.success("test validate");
    }
}

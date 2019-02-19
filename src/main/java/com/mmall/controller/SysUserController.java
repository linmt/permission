package com.mmall.controller;

import com.mmall.beans.PageQuery;
import com.mmall.beans.PageResult;
import com.mmall.common.JsonData;
import com.mmall.model.SysUser;
import com.mmall.param.UserParam;
import com.mmall.service.SysUserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;

@Controller
@RequestMapping("/sys/user")
public class SysUserController {

    @Resource
    private SysUserService sysUserService;
//    @Resource
//    private SysTreeService sysTreeService;
//    @Resource
//    private SysRoleService sysRoleService;
//
//    @RequestMapping("/noAuth.page")
//    public ModelAndView noAuth() {
//        return new ModelAndView("noAuth");
//    }

    @RequestMapping("/save.json")
    @ResponseBody
    public JsonData saveUser(UserParam param) {
        sysUserService.save(param);
        return JsonData.success();
    }

    @RequestMapping("/update.json")
    @ResponseBody
    public JsonData updateUser(UserParam param) {
        sysUserService.update(param);
        return JsonData.success();
    }

    @RequestMapping("/page.json")
    @ResponseBody
    public JsonData page(@RequestParam("deptId") int deptId, PageQuery pageQuery) {
        System.out.println("===========");
//        System.out.println(pageQuery.getPageNo()+"  "+pageQuery.getPageSize());
        System.out.println("deptId:"+deptId+",pageQuery:"+pageQuery);
        PageResult<SysUser> result = sysUserService.getPageByDeptId(deptId, pageQuery);
        System.out.println("===========");
        System.out.println(result.getData().size()+"  "+result.getTotal());
        return JsonData.success(result);
    }

//    @RequestMapping("/acls.json")
//    @ResponseBody
//    public JsonData acls(@RequestParam("userId") int userId) {
//        Map<String, Object> map = Maps.newHashMap();
//        map.put("acls", sysTreeService.userAclTree(userId));
//        map.put("roles", sysRoleService.getRoleListByUserId(userId));
//        return JsonData.success(map);
//    }
}

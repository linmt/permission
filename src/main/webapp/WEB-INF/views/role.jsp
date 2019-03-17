<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>角色</title>
    <jsp:include page="/common/backend_common.jsp" />
    <link rel="stylesheet" href="/ztree/zTreeStyle.css" type="text/css">
    <link rel="stylesheet" href="/assets/css/bootstrap-duallistbox.min.css" type="text/css">
    <script type="text/javascript" src="/ztree/jquery.ztree.all.min.js"></script>
    <script type="text/javascript" src="/assets/js/jquery.bootstrap-duallistbox.min.js"></script>
    <style type="text/css">
        .bootstrap-duallistbox-container .moveall, .bootstrap-duallistbox-container .removeall {
            width: 50%;
        }
        .bootstrap-duallistbox-container .move, .bootstrap-duallistbox-container .remove {
            width: 49%;
        }
    </style>
</head>
<body class="no-skin" youdao="bind" style="background: white">
<input id="gritter-light" checked="" type="checkbox" class="ace ace-switch ace-switch-5"/>
<div class="page-header">
    <h1>
        角色管理
        <small>
            <i class="ace-icon fa fa-angle-double-right"></i>
            维护角色与用户, 角色与权限关系
        </small>
    </h1>
</div>
<div class="main-content-inner">
    <div class="col-sm-3">
        <div class="table-header">
            角色列表&nbsp;&nbsp;
            <a class="green" href="#">
                <i class="ace-icon fa fa-plus-circle orange bigger-130 role-add"></i>
            </a>
        </div>
        <div id="roleList"></div>
    </div>
    <div class="col-sm-9">
        <div class="tabbable" id="roleTab">
            <ul class="nav nav-tabs">
                <li class="active">
                    <a data-toggle="tab" href="#roleAclTab">
                        角色与权限
                    </a>
                </li>
                <li>
                    <a data-toggle="tab" href="#roleUserTab">
                        角色与用户
                    </a>
                </li>
            </ul>
            <div class="tab-content">
                <div id="roleAclTab" class="tab-pane fade in active">
                    <ul id="roleAclTree" class="ztree"></ul>
                    <button class="btn btn-info saveRoleAcl" type="button">
                        <i class="ace-icon fa fa-check bigger-110"></i>
                        保存
                    </button>
                </div>

                <div id="roleUserTab" class="tab-pane fade" >
                    <div class="row">
                        <div class="box1 col-md-6">待选用户列表</div>
                        <div class="box1 col-md-6">已选用户列表</div>
                    </div>
                    <select multiple="multiple" size="10" name="roleUserList" id="roleUserList" >
                    </select>
                    <div class="hr hr-16 hr-dotted"></div>
                    <button class="btn btn-info saveRoleUser" type="button">
                        <i class="ace-icon fa fa-check bigger-110"></i>
                        保存
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
<div id="dialog-role-form" style="display: none;">
    <form id="roleForm">
        <table class="table table-striped table-bordered table-hover dataTable no-footer" role="grid">
            <tr>
                <td><label for="roleName">名称</label></td>
                <td>
                    <input type="text" name="name" id="roleName" value="" class="text ui-widget-content ui-corner-all">
                    <input type="hidden" name="id" id="roleId"/>
                </td>
            </tr>
            <tr>
                <td><label for="roleStatus">状态</label></td>
                <td>
                    <select id="roleStatus" name="status" data-placeholder="状态" style="width: 150px;">
                        <option value="1">可用</option>
                        <option value="0">冻结</option>
                    </select>
                </td>
            </tr>
            <td><label for="roleRemark">备注</label></td>
            <td><textarea name="remark" id="roleRemark" class="text ui-widget-content ui-corner-all" rows="3" cols="25"></textarea></td>
            </tr>
        </table>
    </form>
</div>
<script id="roleListTemplate" type="x-tmpl-mustache">
<ol class="dd-list ">
    {{#roleList}}
        <li class="dd-item dd2-item role-name" id="role_{{id}}" href="javascript:void(0)" data-id="{{id}}">
            <div class="dd2-content" style="cursor:pointer;">
            {{name}}
            <span style="float:right;">
                <a class="green role-edit" href="#" data-id="{{id}}" >
                    <i class="ace-icon fa fa-pencil bigger-100"></i>
                </a>
                &nbsp;
                <a class="red role-delete" href="#" data-id="{{id}}" data-name="{{name}}">
                    <i class="ace-icon fa fa-trash-o bigger-100"></i>
                </a>
            </span>
            </div>
        </li>
    {{/roleList}}
</ol>
</script>

<script id="selectedUsersTemplate" type="x-tmpl-mustache">
{{#userList}}
    <option value="{{id}}" selected="selected">{{username}}</option>
{{/userList}}
</script>

<script id="unSelectedUsersTemplate" type="x-tmpl-mustache">
{{#userList}}
    <option value="{{id}}">{{username}}</option>
{{/userList}}
</script>

<script type="text/javascript">
    $(function () {
        var roleMap = {};
        var lastRoleId = -1;
        var selectFirstTab = true;
        var hasMultiSelect = false;
        
        var roleListTemplate = $("#roleListTemplate").html();
        Mustache.parse(roleListTemplate);
        var selectedUsersTemplate = $("#selectedUsersTemplate").html();
        Mustache.parse(selectedUsersTemplate);
        var unSelectedUsersTemplate = $("#unSelectedUsersTemplate").html();
        Mustache.parse(unSelectedUsersTemplate);
        
        loadRoleList();

        //加载角色列表
        function loadRoleList() {
            $.ajax({
                url: "/sys/role/list.json",
                success: function (result) {
                    if (result.ret) {
                        var rendered = Mustache.render(roleListTemplate, {roleList: result.data});
                        $("#roleList").html(rendered);
                        bindRoleClick();
                        $.each(result.data, function(i, role) {
                            roleMap[role.id] = role;
                        });
                    } else {
                        showMessage("加载角色列表", result.msg, false);
                    }
                }
            });
        }

        //新增角色
        $(".role-add").click(function () {
            $("#dialog-role-form").dialog({
                model: true,
                title: "新增角色",
                open: function(event, ui) {
                    $(".ui-dialog-titlebar-close", $(this).parent()).hide();
                    $("#roleForm")[0].reset();
                },
                buttons : {
                    "添加": function(e) {
                        e.preventDefault();
                        updateRole(true, function (data) {
                            $("#dialog-role-form").dialog("close");
                        }, function (data) {
                            showMessage("新增角色", data.msg, false);
                        })
                    },
                    "取消": function () {
                        $("#dialog-role-form").dialog("close");
                    }
                }
            })
        });

        //插入 更新
        function updateRole(isCreate, successCallback, failCallback) {
            $.ajax({
                url: isCreate ? "/sys/role/save.json" : "/sys/role/update.json",
                data: $("#roleForm").serializeArray(),
                type: 'POST',
                success: function(result) {
                    if (result.ret) {
                        loadRoleList();
                        if (successCallback) {
                            successCallback(result);
                        }
                    } else {
                        if (failCallback) {
                            failCallback(result);
                        }
                    }
                }
            })
        }

        function bindRoleClick() {
            $(".role-edit").click(function (e) {
                e.preventDefault();
                e.stopPropagation();
                var roleId = $(this).attr("data-id");
                $("#dialog-role-form").dialog({
                    model: true,
                    title: "修改角色",
                    open: function(event, ui) {
                        $(".ui-dialog-titlebar-close", $(this).parent()).hide();
                        $("#roleForm")[0].reset();
                        var targetRole = roleMap[roleId];
                        if (targetRole) {
                            $("#roleId").val(roleId);
                            $("#roleName").val(targetRole.name);
                            $("#roleStatus").val(targetRole.status);
                            $("#roleRemark").val(targetRole.remark);
                        }
                    },
                    buttons : {
                        "修改": function(e) {
                            e.preventDefault();
                            updateRole(false, function (data) {
                                $("#dialog-role-form").dialog("close");
                            }, function (data) {
                                showMessage("修改角色", data.msg, false);
                            })
                        },
                        "取消": function () {
                            $("#dialog-role-form").dialog("close");
                        }
                    }
                })
            });
            $(".role-name").click(function (e) {
                e.preventDefault();
                e.stopPropagation();
                var roleId = $(this).attr("data-id");
                handleRoleSelected(roleId);
            });
        }

        function handleRoleSelected(roleId) {
            if (lastRoleId != -1) {
                var lastRole = $("#role_" + lastRoleId + " .dd2-content:first");
                lastRole.removeClass("btn-yellow");
                lastRole.removeClass("no-hover");
            }
            var currentRole = $("#role_" + roleId + " .dd2-content:first");
            currentRole.addClass("btn-yellow");
            currentRole.addClass("no-hover");
            lastRoleId = roleId;

            $('#roleTab a:first').trigger('click');
            if (selectFirstTab) {
                loadRoleAcl(roleId);
            }
        }

        function loadRoleAcl(selectedRoleId) {
            //-1是默认的值，表示没有选中
            if (selectedRoleId == -1) {
                return;
            }
            $.ajax({
                url: "/sys/role/roleTree.json",
                data : {
                    roleId: selectedRoleId
                },
                type: 'POST',
                success: function (result) {
                    if (result.ret) {
                        renderRoleTree(result.data);
                    } else {
                        showMessage("加载角色权限数据", result.msg, false);
                    }
                }
            });
        }

        /*
        为什么把权限点信息放入zTreeObj，而权模块信息放入nodeMap？
        首次读取aclModule的时候，不知道它下面的层级结构是什么样的，因此后面会有一个刷新的过程，
        这个刷新的过程会改掉之前的值，因此暂时把权限模块的值放入nodeMap中，等整个递归处理完后，nodeMap中的值固定了，才能写入zTreeObj
        */
        //使用ztree插件渲染
        function renderRoleTree(aclModuleList) {
            //准备数据
            //1.清空
            zTreeObj = [];
            //将权限点信息放在zTreeObj，权限模块信息放入nodeMap
            recursivePrepareTreeData(aclModuleList);
            for(var key in nodeMap) {
                zTreeObj.push(nodeMap[key]);
            }
            $.fn.zTree.init($("#roleAclTree"), setting, zTreeObj);
        }

        //将权限点信息放在zTreeObj，权限模块信息放入nodeMap
        function recursivePrepareTreeData(aclModuleList) {
            // prepare nodeMap
            if (aclModuleList && aclModuleList.length > 0) {
                $(aclModuleList).each(function(i, aclModule) {
                    //标记是否需要勾选
                    var hasChecked = false;
                    //判断下面是否包含权限点
                    if (aclModule.aclList && aclModule.aclList.length > 0) {
                        $(aclModule.aclList).each(function(i, acl) {
                            zTreeObj.push({
                                id: aclPrefix + acl.id,
                                pId: modulePrefix + acl.aclModuleId,     //挂在那个模块下
                                name: acl.name + ((acl.type == 1) ? '(菜单)' : ''),
                                chkDisabled: !acl.hasAcl,   //？？？
                                checked: acl.checked,   //是否被选中
                                dataId: acl.id
                            });
                            //true代表下面有权限点，被选中，是否允许打开
                            if(acl.checked) {
                                hasChecked = true;
                            }
                        });
                    }
                    //对权限模块进行处理，将数据放入nodeMap
                    //判断是否有子模块 或者  权限点
                    if ((aclModule.aclModuleList && aclModule.aclModuleList.length > 0) ||
                        (aclModule.aclList && aclModule.aclList.length > 0)) {
                        nodeMap[modulePrefix + aclModule.id] = {
                            id : modulePrefix + aclModule.id,
                            pId: modulePrefix + aclModule.parentId,
                            name: aclModule.name,
                            //有权限的话，则允许打开
                            open: hasChecked
                        };
                        //让上一层的模块也为true
                        var tempAclModule = nodeMap[modulePrefix + aclModule.id];
                        while(hasChecked && tempAclModule) {
                            if(tempAclModule) {
                                nodeMap[tempAclModule.id] = {
                                    id: tempAclModule.id,
                                    pId: tempAclModule.pId,
                                    name: tempAclModule.name,
                                    open: true
                                }
                            }
                            //tempAclModule处理完自己之后，让tempAclModule等于它上一层的模块
                            tempAclModule = nodeMap[tempAclModule.pId];
                        }
                    }
                    recursivePrepareTreeData(aclModule.aclModuleList);
                });
            }
        }

        // zTree
        <!-- 树结构相关 开始 -->
        var zTreeObj = [];         //实际中传给树形结构的数据
        var modulePrefix = 'm_';  //前缀
        var aclPrefix = 'a_';     //前缀
        var nodeMap = {};          //存储相关的数据，为了生成zTreeObj中的数据

        /*
         enable：true / false 分别表示 显示 / 不显示 复选框或单选框
         chkboxType：
             Y 属性定义 checkbox 被勾选后的情况；
             N 属性定义 checkbox 取消勾选后的情况；
             "p" 表示操作会影响父级节点；
             "s" 表示操作会影响子级节点。
             请注意大小写，不要改变
         chkDisabledInherit：
             true 表示 新加入子节点时，自动继承父节点 chkDisabled = true 的属性。
             false 表示 新加入子节点时，不继承父节点 chkDisabled 的属性。
         autoCheckTrigger：true / false 分别表示 触发 / 不触发 事件回调函数
         */
        var setting = {
            check: {
                enable: true,
                chkDisabledInherit: true,
                chkboxType: {"Y": "ps", "N": "ps"}, //auto check 父节点 子节点
                autoCheckTrigger: true
            },
            data: {
                simpleData: {
                    enable: true,
                    rootPId: 0
                }
            },
            callback: {
                onClick: onClickTreeNode
            }
        };

        //每次点击节点的时候都尝试打开节点，相当于树形结构不停的展开叠起
        function onClickTreeNode(e, treeId, treeNode) { // 绑定单击事件
            var zTree = $.fn.zTree.getZTreeObj("roleAclTree");
            zTree.expandNode(treeNode);
        }

        //获取当前ztree中选中节点的id
        function getTreeSelectedId() {
            var treeObj = $.fn.zTree.getZTreeObj("roleAclTree");
            var nodes = treeObj.getCheckedNodes(true);
            var v = "";
            for(var i = 0; i < nodes.length; i++) {
                //只处理权限点的
                if(nodes[i].id.startsWith(aclPrefix)) {
                    v += "," + nodes[i].dataId;
                }
            }
            //移除第一个逗号
            return v.length > 0 ? v.substring(1): v;
        }

        $(".saveRoleAcl").click(function (e) {
            e.preventDefault();
            if (lastRoleId == -1) {
                showMessage("保存角色与权限点的关系", "请现在左侧选择需要操作的角色", false);
                return;
            }
            $.ajax({
                url: "/sys/role/changeAcls.json",
                data: {
                    roleId: lastRoleId,
                    aclIds: getTreeSelectedId()
                },
                type: 'POST',
                success: function (result) {
                    if (result.ret) {
                        showMessage("保存角色与权限点的关系", "操作成功", false);
                    } else {
                        showMessage("保存角色与权限点的关系", result.msg, false);
                    }
                }
            });
        });

        $("#roleTab a[data-toggle='tab']").on("shown.bs.tab", function(e) {
            //还没选中角色时
            if(lastRoleId == -1) {
                showMessage("加载角色关系","请先在左侧选择操作的角色", false);
                return;
            }
            if (e.target.getAttribute("href") == '#roleAclTab') {
                selectFirstTab = true;
                loadRoleAcl(lastRoleId);
            } else {
                selectFirstTab = false;
                loadRoleUser(lastRoleId);
            }
        });

        function loadRoleUser(selectedRoleId) {
            $.ajax({
                url: "/sys/role/users.json",
                data: {
                    roleId: selectedRoleId
                },
                type: 'POST',
                success: function (result) {
                    if (result.ret) {
                        var renderedSelect = Mustache.render(selectedUsersTemplate, {userList: result.data.selected});
                        var renderedUnSelect = Mustache.render(unSelectedUsersTemplate, {userList: result.data.unselected});
                        $("#roleUserList").html(renderedSelect + renderedUnSelect);

                        //是否处理过
                        if(!hasMultiSelect) {
                            $('select[name="roleUserList"]').bootstrapDualListbox({
                                showFilterInputs: false,  //不过滤
                                moveOnSelect: false,       //不想点击之后就选中
                                infoText: false
                            });
                            hasMultiSelect = true;
                        } else {
                            $('select[name="roleUserList"]').bootstrapDualListbox('refresh', true);
                        }
                    } else {
                        showMessage("加载角色用户数据", result.msg, false);
                    }
                }
            });
        }

        $(".saveRoleUser").click(function (e) {
            e.preventDefault();
            if (lastRoleId == -1) {
                showMessage("保存角色与用户的关系", "请现在左侧选择需要操作的角色", false);
                return;
            }
            $.ajax({
                url: "/sys/role/changeUsers.json",
                data: {
                    roleId: lastRoleId,
                    userIds: $("#roleUserList").val() ? $("#roleUserList").val().join(",") : ''
                },
                type: 'POST',
                success: function (result) {
                    if (result.ret) {
                        showMessage("保存角色与用户的关系", "操作成功", false);
                    } else {
                        showMessage("保存角色与用户的关系", result.msg, false);
                    }
                }
            });
        });
    });
</script>
</body>
</html>

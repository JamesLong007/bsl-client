//解决点击延迟问题
new FastClick(document.body);

var packageName = "";

var modules;

var myScroll = new iScroll('mainContent', {
	checkDOMChanges: true
});

$("#search_del").click(function() {
	console.log("点击了图标");
	$("#searchInput").val("");
	$(this).hide();
});

// 检测屏幕是否伸缩
$(window).resize(function() {
	$(".mainContent").height($(window).height() - 50);
});

//封装cordova的执行方法，加上回调函数
var cordovaExec = function(plugin, action, parameters, callback) {
	cordova.exec(function(data) {
		if (callback !== undefined) {
			callback();
		}
	}, function(err) {
		//alert(err);
	}, plugin, action, parameters === null || parameters === undefined ? [] : parameters);
};
//自动更新查新界面
var refreshMainPage = function() {
	var page = $(".menuItem.active").attr("data");
	alert("page" + page);
	console.log("refreshMainPage page = " + page);
	if (page === "home") {
		//主页面
		loadModuleList("CubeModuleList", "mainList", "main");
	} else if (page === "module") {
		//管理页面
		//loadModuleList("CubeModuleList", "uninstallList", "install");
		var type = $(".moduleManageBar .manager-btn.active").attr("data");
		if (type === "uninstall") {
			loadModuleList("CubeModuleList", "uninstallList", "uninstall");
		} else if (type === "install") {
			loadModuleList("CubeModuleList", "installList", "install");
		} else if (type === "upgrade") {
			loadModuleList("CubeModuleList", "upgradableList", "upgrade");
		}
	}
};
//首页接受到信息，刷新页面
var receiveMessage = function(identifier, count, display) {
	var $moduleTips = $(".moduleContent[moduletype='main'][identifier='" + identifier + "']").find(".moduleTips");
	console.log("receiveMessage count display " + display);
	if (display) {
		console.log("receiveMessage count 进入display");
		if (count !== 0) {
			$moduleTips.html(count).show();
		} else {
			$moduleTips.hide();
		}
	} else {
		$moduleTips.hide();
	}

	triggerBodyClick();
};

var updateProgress = function(identifier, count) {

};
//模块增删，刷新模块列表(uninstall，install，upgrade)
var refreshModule = function(identifier, type, moduleMessage) {
	console.info(identifier + "===" + type + "===");
	if (type === "uninstall") {
		//已安装减一个
		console.log("删除了刷新" + $(".moduleContent[moduletype='install'][identifier='" + identifier + "']").size());
		$(".moduleContent[moduletype='install'][identifier='" + identifier + "']").remove();

		//未安装加一个
		addModule(identifier, "uninstall", moduleMessage);
		//更新有则减
		$(".moduleContent[moduletype='upgrade'][identifier='" + identifier + "']").remove();
		console.log("删除了刷新完成");
	} else if (type === "install") {
		//未安装减一个
		console.log("安装了刷新");
		$(".moduleContent[moduletype='uninstall'][identifier='" + identifier + "']").remove();
		//已安装加一个
		console.log("安装了刷新完成");
		addModule(identifier, "install", moduleMessage);
		//更新不变
	} else if (type === "upgrade") {
		//已安装替换
		addModule(identifier, "install", moduleMessage);
		//更新减一个
		$(".moduleContent[moduletype='upgrade'][identifier='" + identifier + "']").remove();
		//未安装不变
	} else if (type === "main") {
		addModule(identifier, "main", moduleMessage);
	}

	// 绑定左边图标菜单按钮事件
	checkModule();
	triggerBodyClick();
};

//检查模块信息的完整性，如果没有模块，则隐藏
var checkModule = function() {
	$.each($(".moduleTitle"), function(index, data) {
		if ($(this).next().attr("identifier") === null || $(this).next().attr("identifier") === undefined) {
			$(this).remove();
		}
	});
};

var addModule = function(identifier, type, moduleMessage) {
	var mm = $.parseJSON(moduleMessage);
	//如果该模块不存在，则生成
	if ($(".moduleTitle[modulename='" + mm.category + "']").size() < 1) {
		//获取模板名
		var moduleContentTemplate = $("#moduleContentTemplate").html();

		var moduleContentHtml = _.template(moduleContentTemplate, {
			'moduleTitle': mm.category,
			'moduleItem': "",
			'moduleType': type
		});
		$(".mainContent").find(".scrollContent").append(moduleContentHtml);
	}

	//如果存在，先删除，再添加
	if ($("li[identifier='" + identifier + "']").size() > 0) {
		$("li[identifier='" + identifier + "']").remove();
	}

	var moduleItemTemplate = $("#moduleItemTemplate").html();

	mm.moduleType = type;
	mm.classname = mm.category;

	var moduleItemHtml = _.template(moduleItemTemplate, mm);

	if ($(".moduleManageBar .manager-btn.active").attr("data") === type && mm.hidden === false) {
		$(".moduleTitle[modulename='" + mm.category + "'][moduletype='" + type + "']").after(moduleItemHtml);
	}

	triggerBodyClick();

};

//点击左边菜单
$(".menuItem").tap(function() {
	var type = $(this).attr("data");
	$(".menuItem").removeClass("active");
	$(this).addClass("active");

	//清除搜索框数据
	$("#searchInput").val("");
	if (type === "home") {
		//非管理页面，隐藏管理菜单
		$(".moduleManageBar").css("display", "none");
		$('.account_content').show();
		//点击首页，加载首页已安装模块列表
		loadModuleList("CubeModuleList", "mainList", "main");
	} else if (type === "module") {
		$(".moduleManageBar").css("display", "block");
		$('.account_content').hide();
		activeModuleManageBarItem("uninstall");
		//点击模块管理，加载未安装模块列表(先同步，再获取未安装列表)
		cordovaExec("CubeModuleOperator", "sync", [], function() {
			loadModuleList("CubeModuleList", "uninstallList", "uninstall");
		});

	} else if (type === "chat") {} else if (type === "setting") {
		cordovaExec("CubeModuleOperator", "setting");
	} else if (type === "skin") {
		// replacejscssfile("theme/default/default.css", "theme/wood/wood.css", "css");
		cordovaExec("CubeModuleOperator", "setTheme");
	}
});

//选中模块操作菜单，传入需要激活的按钮名称（uninstall，install，upgrade）
var activeModuleManageBarItem = function(type) {
	//移除所有选中
	$(".moduleManageBar .manager-btn").removeClass("active");
	//选中当前点击
	$(".moduleManageBar .manager-btn[data='" + type + "']").addClass("active");

};

//点击模块管理按钮
$(".moduleManageBar .manager-btn").click(function() {
	var type = $(this).attr("data");
	if (!$(this).hasClass("active")) {
		$("#searchInput").val("");
		//点击操作
		if (type === "uninstall") {
			loadModuleList("CubeModuleList", "uninstallList", "uninstall");
		} else if (type === "install") {
			loadModuleList("CubeModuleList", "installList", "install");
		} else if (type === "upgrade") {
			loadModuleList("CubeModuleList", "upgradableList", "upgrade");
		}
	}
});

//搜索框事件
$("#searchInput").focusin(function() {
	$(".bottomMenu").hide();
}).focusout(function() {
	$(".bottomMenu").show();
});

$("#searchInput").live("input propertychange", function() {
	var me = $(this);
	console.log(me.val());
	if (me.val() === null || me.val() === undefined || me.val() === "") {
		$("#search_del").hide();
	} else {
		$("#search_del").css("display", "inline");
	}
	var moduleList = $("li[identifier]");
	var moduleTitleLists = $(".moduleTitle");
	//全部标题隐藏
	moduleTitleLists.hide();

	$.each(moduleList, function(index, data) {
		var name = $(this).find(".moduleName").html();
		//console.info($(this).find(".moduleName").toPinyin());
		var classname = $(this).attr("classname");
		if (name.indexOf(me.val()) < 0) {
			$(this).hide();
		} else {
			$(this).show();
			//有显示列表内容的，显示标题
			$.each(moduleTitleLists, function(i, moduleTitleList) {
				var title = $(moduleTitleList).attr("modulename");
				if (title == classname) {
					console.log("相等");
					$(moduleTitleList).show();
				}
			});


		}
	});
});

//点击模块的时候触发事件
$("li[identifier]").live("click", function() {
	var type = $(this).attr("moduleType");
	var identifier = $(this).attr("identifier");
	cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);
});

//获取用户信息
var getAccountName = function() {
	var accountName = "";
	//获取用户名
	cordova.exec(function(account) {
		console.log("进入exec获取accountName");
		var a = $.parseJSON(account);
		accountName = a.accountname;
	}, function(err) {
		accountName = "";
	}, "CubeAccount", "getAccount", []);
	console.log("获取完成");
	if (accountName !== "") {
		accountName = " " + accountName + " ";
	}
	$('.account_content').html("<h4>欢迎" + accountName + "登录</h4>");

	console.log("初始化account_content完成");
};

//加载列表，渲染成html
var loadModuleList = function(plugin, action, type, callback) {

	$(".mainContent").remove();
	var mainContent = $('<div id="mainContent" class="mainContent"><div id="scroller"><ul class="scrollContent nav nav-list bs-docs-sidenav affix-top"></ul></div></div>');
	$(".middleContent").append(mainContent);
	var allModuleContentHtml = "";

	cordova.exec(function(data) {
		data = $.parseJSON(data);
		//处理成功加载首页模块列表
		_.each(data, function(value, key) {
			var moduleItemHtmlContent = "";
			var moduleItemTemplate = $("#moduleItemTemplate").html();
			_.each(value, function(value) {
				value.moduleType = type;
				//处理，只有在首页的时候才显示有统计数据
				if (type !== "main") {
					value.msgCount = 0;
				}
				//更新的图标，如果在未安装里面，不应该出现
				if (type === 'uninstall') {
					value.updatable = false;
				}

				value.name = subStrByCnLen(value.name, 7);
				value.releaseNote = subStrByCnLen(value.releaseNote, 25);
				// packageName
                   /*
				downloadFile(value.icon, packageName + "/moduleIcon", function(entry) {
					// document.body.innerHTML = "<img src  = " + entry.fullPath + ">";
					value.icon = entry.fullPath;
				});
                    */
				value.classname = key;
				var moduleItemHtml = _.template(moduleItemTemplate, value);
				moduleItemHtmlContent = moduleItemHtmlContent + moduleItemHtml;
			});
			//获取模板名
			var moduleContentTemplate = $("#moduleContentTemplate").html();

			var moduleContentHtml = _.template(moduleContentTemplate, {
				'moduleTitle': key,
				'moduleItem': moduleItemHtmlContent,
				'moduleType': type
			});
			if (moduleItemHtmlContent.trim().length > 0) {
				allModuleContentHtml = allModuleContentHtml + moduleContentHtml;
			}
		});
		$(".mainContent").find(".scrollContent").append(allModuleContentHtml);

		$(".mainContent").height($(window).height() - 50);

		if (myScroll !== null) {
			myScroll = null;
		}
		myScroll = new iScroll('mainContent', {
			checkDOMChanges: true
		});
		//切换模块管理按钮状态
		activeModuleManageBarItem(type);
		triggerBodyClick();

		//如果回调方法不为空，则执行该回调方法
		if (callback !== undefined) {
			callback();
		}

	}, function(err) {
		//showAlert(err, null, "提示", "确定");
	}, plugin, action, []);

};

var triggerBodyClick = function() {
	setTimeout(function() {
		$("#mainContent").trigger("click");
		if (myScroll !== null) {
			myScroll.refresh();
			myScroll.scrollTo(0, 1, 200, true);
		}
	}, 500);
};


//修改主题，根据客户端传过来的名字，切换到相应的主题
var changeTheme = function(name) {
	var current = Store.loadObject("theme");
	if (current !== name) {
		replacejscssfile("theme/" + current + "/" + current + ".css", "theme/" + name + "/" + name + ".css", "css");
		//设置主题的同时，记录当前主题值
		Store.saveObject("theme", name);

		$(".mainBg").each(function() {
			if ($(this).attr("data") === name) {
				$(this).remove();
				$("body").append($(this).removeClass("a-fadeout a-fadein").addClass("a-fadein"));
			}
		});
	}
};


//检查主题，并设置
var checkTheme = function() {
	var theme = Store.loadObject("theme");
	var lastMainBg = "";
	$.getJSON("theme/theme.json", function(data) {
		var mainBgTemplate = $("#mainBgTemplate").html();
		_.each(data, function(value) {
			value.img = "../pad" + value.img;
			var mainBgContentItemHtml = _.template(mainBgTemplate, value);
			if (theme === null && mainBgContentItemHtml.indexOf("default") > -1) {
				lastMainBg = mainBgContentItemHtml;
			} else if (theme !== null && mainBgContentItemHtml.indexOf(theme) > -1) {
				lastMainBg = mainBgContentItemHtml;
			} else {
				$("body").append(mainBgContentItemHtml);
			}
		});
		$("body").append(lastMainBg);
		replacejscssfile("theme/default/default.css", "theme/" + theme + "/" + theme + ".css", "css");
	});

};
//var myScroll = null;
//应用初始化
var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		app.receivedEvent('deviceready');
	},
	receivedEvent: function(id) {
		getAccountName();
		//loadModuleList("CubeModuleList", "mainList", "main");
//		cordovaExec("CubeModuleOperator", "sync", [], function() {
//			var osPlatform = device.platform;
//			if (osPlatform == "android") {
//				cordova.exec(function(data) {
//					packageName = data;
//					//如果是android，先获取到包名
//					loadModuleList("CubeModuleList", "mainList", "main", function() {
//						myScroll.refresh();
//						checkTheme();
//					});
//				}, function(err) {}, "CubePackageName", "getPackageName", []);
//			} else {
				loadModuleList("CubeModuleList", "mainList", "main", function() {
					myScroll.refresh();
					checkTheme();
				});
//			}
//		});
	}
};
app.initialize();
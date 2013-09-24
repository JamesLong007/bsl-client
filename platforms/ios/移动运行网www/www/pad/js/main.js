//解决点击延迟问题
new FastClick(document.body);

var modules;

$("#search_del").click(function() {
	console.log("点击了图标");
	$("#searchInput").val("");
	$(this).hide();
});
$("#searchInput").blur(function() {
	console.log("离开了");
	$("leftContent").click();
	$(".bottomMenu").show();
});
$("#searchInput").focus(function() {
	$(".bottomMenu").hide();
	console.log("聚焦了");
});
// 检测屏幕是否伸缩
$(window).resize(function() {
	$(".mainContent").height($(window).height() - 50);
});
var refreshMainPage = function() {

	loadModuleList("CubeModuleList", "mainList", "main");
}
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

//首页接受到信息，刷新页面
var receiveMessage = function(identifier, count) {
	var $moduleTips = $(".moduleContent[moduletype='main'][identifier='" + identifier + "']").find(".moduleTips");
	if (count !== 0) {
		$moduleTips.html(count).show();
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

	$(".moduleTitle[modulename='" + mm.category + "'][moduletype='" + type + "']").after(moduleItemHtml);

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
		activeModuleManageBarItem(type);
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

// $("#searchInput").live("input propertychange", function() {
// 	var me = $(this);
// 	console.log(me.val());
// 	if (me.val() === null || me.val() === undefined || me.val() === "") {
// 		$("#search_del").hide();
// 	} else {
// 		$("#search_del").css("display", "inline");
// 	}
// 	var moduleList = $("li[identifier]");
// 	var moduleTitleLists = $(".moduleTitle");
// 	//全部标题隐藏
// 	moduleTitleLists.hide();

// 	$.each(moduleList, function(index, data) {
// 		var name = $(this).find(".moduleName").html();
// 		//console.info($(this).find(".moduleName").toPinyin());
// 		var classname = $(this).attr("classname");
// 		if (name.indexOf(me.val()) < 0) {
// 			$(this).hide();
// 		} else {
// 			$(this).show();
// 			//有显示列表内容的，显示标题
// 			$.each(moduleTitleLists, function(i, moduleTitleList) {
// 				var title = $(moduleTitleList).attr("modulename");
// 				if (title == classname) {
// 					console.log("相等");
// 					$(moduleTitleList).show();
// 				}
// 			});


// 		}
// 	});


// });

//点击模块的时候触发事件
$("li[identifier]").live("click", function() {
	var type = $(this).attr("moduleType");
	var identifier = $(this).attr("identifier");
	cordovaExec("CubeModuleOperator", "showModule", [identifier, type]);
});
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
				// var mark = value.icon;
				// if (mark.indexOf("?") > -1) {
				// 	mark = mark.substring(0, mark.indexOf("?"));
				// }
				// if (window.localStorage[mark] !== undefined) {
				// 	value.icon = window.localStorage[mark];
				// }
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

		// if (!browser.versions.android) {
		var myScroll = new iScroll('mainContent');
		// }

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
		socLogin();
		getAccountName();
		//loadModuleList("CubeModuleList", "mainList", "main");
		cordovaExec("CubeModuleOperator", "sync", [], function() {
			loadModuleList("CubeModuleList", "mainList", "main");
		});
		checkTheme();
	}
};
app.initialize();



//登陆
var socLogin = function() {

	getDate();

	$("#loader").attr({
		'style': 'display:block'
	});
	var username = window.localStorage["username"];
	var password = window.localStorage["password"];



	$.ajax({
		timeout: 2000 * 1000,
		url: "http://10.103.124.104:8080/opws-mobile-web/j_spring_security_check",
		type: "get",
		data: {
			"j_username": username,
			"j_password": password
		},
		dataType: "json",
		success: function(data, textStatus, jqXHR) {
			console.log('列表数据加载成功：' + textStatus + " response:[" + data + "]");



			if (data.login === true) {


				window.localStorage["logigMessage"] = JSON.stringify(data);
				getWeather();

			} else {


				closeLoader();


				Toast("登陆失败,请检查用户名和密码!", null);
			}


		},
		error: function(e, xhr, type) {


			console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);
			closeLoader();


			Toast("登陆失败,请检查网络连接!", null);
		}
	});


};

//获取天气信息
var getWeather = function() {

	//admin登陆后台接口传过来的基地为null，默认为广州
	var loginMessage = JSON.parse(window.localStorage["logigMessage"]);
	var base = "广州"; //loginMessage.userInfo.base;

	$("#base").html(base);

	$.ajax({
		timeout: 2000 * 1000,
		url: "http://10.103.124.104:8080/opws-mobile-web/mobile/flightinfo-FlightWeather-findWeather.action",
		type: "get",
		data: {
			"optArea": base
		},
		dataType: "json",
		success: function(data, textStatus, jqXHR) {
			console.log('列表数据加载成功：' + textStatus + " response:[" + data + "]");



			$("#weather").html(data.weather.rmk);
			$("#degree").html(data.weather.tempreture + "°");

		},
		error: function(e, xhr, type) {


			console.error('列表数据加载失败：' + e + "/" + type + "/" + xhr);

			Toast("加载天气信息失败!", null);

		},

		complete: function(xhr, status) {

			closeLoader();



		}
	});

};

var closeLoader = function() {



	$("#loader").attr({
		'style': 'display:none'
	});
};


//冒泡提示信息: msg:提示内容, duration:停留时间
var Toast = function(msg, duration) {
	duration = isNaN(duration) ? 3000 : duration;
	var m = document.createElement('div');
	m.innerHTML = msg;
	m.style.cssText = "width:60%; min-width:150px; background:#000; opacity:0.5; height:40px; color:#fff; line-height:40px; text-align:center; border-radius:5px; position:fixed; top:80%; left:20%; z-index:999999; font-weight:bold;";
	document.body.appendChild(m);
	setTimeout(function() {
		var d = 0.5;
		m.style.webkitTransition = '-webkit-transform ' + d + 's ease-in, opacity ' + d + 's ease-in';
		m.style.opacity = '0';
		setTimeout(function() {
			document.body.removeChild(m);
		}, d * 1000);
	}, duration);
};

var getDate = function() {


	var weekday = new Array(7);
	weekday[1] = "星期一";
	weekday[2] = "星期二";
	weekday[3] = "星期三";
	weekday[4] = "星期四";
	weekday[5] = "星期五";
	weekday[6] = "星期六";
	weekday[0] = "星期日";
	var myDate = new Date();


	var month = myDate.getMonth();

	var currentMonth = parseInt(month) + 1;
	var currentDay = myDate.getDate();
	var day = weekday[myDate.getDay()];


	var date = currentMonth + "月" + currentDay + "日" + " " + day;
	$("#date").html(date);

};
//搜索按键
$("#searchBtn").click(function() {
	//搜索事件
	var keyword = $("#searchInput").val();
	console.log("点击了搜索按键：keyword=" + keyword);


	if (keyword) {
	Toast("航班号或机未号!" + keyword, null);


		var myDate = new Date();


		var month = myDate.getMonth();

		var currentMonth = parseInt(month) + 1;
		var currentDay = myDate.getDate();

		var confirmTime = myDate.getFullYear() + "-" + (currentMonth < 10 ? "0" + currentMonth : currentMonth) + "-" + (currentDay < 10 ? "0" + currentDay : currentDay);


		var queryAction = {
			QueryType: '航班机尾号',
			QueryString: flightQuery + keyword,
			querySite: 'flight',
			queryUrl: UrlConfig.dynamic.findByFltNumOrTailNum,
			requestParams: {
				'fltDt': confirmTime,
				'fltNr': keyword
			},
			fromPage: "home"
		};


		window.localStorage['com.csair.dynamic-flightDynamic.html'] = queryAction;

		window.location = "../../com.csair.dynamic/index.html#com.csair.dynamic/flightDynamic";

	} else {


		Toast("请输入航班号或机未号!", null);

	}

});
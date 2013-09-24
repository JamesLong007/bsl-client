//解决点击延迟问题
new FastClick(document.body);

// $(".mainContent").height($(window).height() - 50);

var myScroll;

// 检测屏幕是否伸缩
$(window).resize(function() {
	$(".mainContent").height($(window).height() - 50);
});
// //使模块列表滚动
// $('.mainContent').iScroll({
// 	checkDOMChanges: true,
// 	useTransition: true
// });

//搜索框事件
$("#searchInput").live("input propertychange", function() {
	var me = $(this);
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
		console.log("classname=" + classname);
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
	});

};

checkTheme();


// $("img").on("load", function() {
// 	console.info("img load ");
// 	console.info($(this));
// 	console.info("img load ");
// });

// 绑定左边图标菜单按钮事件
$(".menuItem").click(function() {
	var type = $(this).attr("data");
	$(".menuItem").parent().removeClass("active");
	$(this).parent().addClass("active");
	if (type === "home") {

	} else if (type === "module") {

	} else if (type === "chat") {

	} else if (type === "setting") {

	} else if (type === "skin") {
		changeTheme("beach");
	}
});

var data = {

	"基本功能": [{
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "http://www.oschina.net/action/user/captcha?sessionkey=fjksdljfklsdjaklfj",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "公告",
		"msgCount": 10,
		"progress": 0,
		"updatable": true,
		"build": 4
	}],
	"基本功能22": [{
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "http://www.baidu.com/img/bdlogo.gif",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "公告",
		"msgCount": 0,
		"progress": 0,
		"updatable": false,
		"build": 4
	}],
	"基本功能22333": [{
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "img/icon-notice22.png",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "公告",
		"msgCount": 0,
		"progress": 0,
		"updatable": false,
		"build": 4
	}],
	"测试一": [{
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "img/icon-notice22.png",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "一",
		"msgCount": 0,
		"progress": 0,
		"updatable": false,
		"build": 4
	}, {
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "img/icon-notice22.png",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "二",
		"msgCount": 0,
		"progress": 0,
		"updatable": false,
		"build": 4
	}, {
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "img/icon-notice22.png",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "三",
		"msgCount": 0,
		"progress": 0,
		"updatable": false,
		"build": 4
	}, {
		"version": "3",
		"releaseNote": "显示系统公告",
		"category": "基本功能",
		"icon": "img/icon-notice22.png",
		"identifier": "com.foss.announcement",
		"local": "com.foreveross.cube.activity.NoticeActivity",
		"name": "公告",
		"msgCount": 0,
		"progress": 0,
		"updatable": false,
		"build": 4
	}],
	"测试二": [{
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}],
	"产品演示222": [{
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}],
	"产品演示33": [{
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}],
	"产品演示44": [{
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}, {
		"version": "1.0.0.60",
		"category": "产品演示",
		"downloadUrl": " ff8080813e1cd6f5013e30c3358701ec",
		"releaseNote": "1.添加起降状态标志 2.界面调整",
		"icon": "img/icon-notice.png",
		"identifier": "com.foss.plane.demo",
		"name": "前序航班-Demo",
		"msgCount": 0,
		"progress": 100,
		"updatable": false,
		"build": 60
	}]

};

$("#searchInput").focusin(function() {
	$(".bottomMenu").hide();
}).focusout(function() {
	$(".bottomMenu").show();
});

$("li[identifier]").live("click", function() {
	//console.info($(this).parent().parent().parent());
});

var loadModuleList = function() {

	myScroll = null;

	$(".mainContent").remove();
	var mainContent = $('<div id="mainContent" class="mainContent"><div id="scroller"><ul class="scrollContent nav nav-list bs-docs-sidenav affix-top"></ul></div></div>');
	$(".middleContent").append(mainContent);

	var allModuleContentHtml = "";
	_.each(data, function(value, key) {
		var moduleItemHtmlContent = "";
		var moduleItemTemplate = $("#moduleItemTemplate").html();
		_.each(value, function(value) {

			var mark = value.icon;
			if (mark.indexOf("?") > -1) {
				mark = mark.substring(0, mark.indexOf("?"));
			}
			if (window.localStorage[mark] !== undefined) {
				// value.icon = window.localStorage[mark];
				//value.icon = store.get(mark);
				value.icon = combineString(mark);

			}

			value.name = subStrByCnLen(value.name, 5);

			value.moduleType = 'main';
			value.classname = key;
			var moduleItemHtml = _.template(moduleItemTemplate, value);
			moduleItemHtmlContent = moduleItemHtmlContent + moduleItemHtml;
		});
		//获取模块名
		var moduleContentTemplate = $("#moduleContentTemplate").html();
		if (moduleItemHtmlContent !== "" || moduleItemHtmlContent !== null) {

		}

		var moduleContentHtml = _.template(moduleContentTemplate, {
			'moduleTitle': key,
			'moduleItem': moduleItemHtmlContent,
			'moduleType': 'main'
		});
		allModuleContentHtml = allModuleContentHtml + moduleContentHtml;
		//使模块列表滚动
	});
	$(".mainContent").find(".scrollContent").append(allModuleContentHtml);

	$(".mainContent").height($(window).height() - 50);

	myScroll = new iScroll('mainContent');

	myScroll.scrollTo(0, 1, 200, true);

	// $('.mainContent').iScroll('refresh');
	// $('img.imageCache').imageCache();
};
loadModuleList();
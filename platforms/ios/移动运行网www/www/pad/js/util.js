//移除js、css文件
var removejscssfile = function(filename, filetype) {
	var targetelement = (filetype == "js") ? "script" : (filetype == "css") ? "link" : "none";
	var targetattr = (filetype == "js") ? "src" : (filetype == "css") ? "href" : "none";
	var allsuspects = document.getElementsByTagName(targetelement);
	for (var i = allsuspects.length; i >= 0; i--) {
		if (allsuspects[i] && allsuspects[i].getAttribute(targetattr) !== null && allsuspects[i].getAttribute(targetattr).indexOf(filename) !== -1);
		allsuspects[i].parentNode.removeChild(allsuspects[i]);
	}
};

//创建js、css文件
var createjscssfile = function(filename, filetype) {
	var fileref;
	if (filetype === "js") {
		fileref = document.createElement('script');
		fileref.setAttribute("type", "text/javascript");
		fileref.setAttribute("src", filename);
	} else if (filetype === "css") {
		fileref = document.createElement("link");
		fileref.setAttribute("rel", "stylesheet");
		fileref.setAttribute("type", "text/css");
		fileref.setAttribute("href", filename);
	}
	return fileref;
};


//替换js、css文件
var replacejscssfile = function(oldfilename, newfilename, filetype) {
	var targetelement = (filetype === "js") ? "script" : (filetype === "css") ? "link" : "none";
	var targetattr = (filetype == "js") ? "src" : (filetype == "css") ? "href" : "none";
	var allsuspects = document.getElementsByTagName(targetelement);
	for (var i = allsuspects.length; i >= 0; i--) {
		if (allsuspects[i] && allsuspects[i].getAttribute(targetattr) !== null && allsuspects[i].getAttribute(targetattr).indexOf(oldfilename) !== -1) {
			var newelement = createjscssfile(newfilename, filetype);
			allsuspects[i].parentNode.replaceChild(newelement, allsuspects[i]);
		}
	}
};


//判断浏览器内核
var browser = {
	versions: function() {
		var u = navigator.userAgent,
			app = navigator.appVersion;
		return {
			trident: u.indexOf('Trident') > -1, //IE内核
			presto: u.indexOf('Presto') > -1, //opera内核
			webKit: u.indexOf('AppleWebKit') > -1, //苹果、谷歌内核
			gecko: u.indexOf('Gecko') > -1 && u.indexOf('KHTML') == -1, //火狐内核
			mobile: !! u.match(/AppleWebKit.*Mobile.*/) || !! u.match(/AppleWebKit/), //是否为移动终端
			ios: !! u.match(/(i[^;]+\;(U;)? CPU.+Mac OS X)/), //ios终端
			android: u.indexOf('Android') > -1 || u.indexOf('Linux') > -1, //android终端或者uc浏览器
			iPhone: u.indexOf('iPhone') > -1 || u.indexOf('Mac') > -1, //是否为iPhone或者QQHD浏览器
			iPad: u.indexOf('iPad') > -1, //是否iPad
			webApp: u.indexOf('Safari') == -1, //是否web应该程序，没有头部与底部
			apad: (u.indexOf('Android') > -1 || u.indexOf('Linux') > -1) && (u.indexOf("Mobile") < 0)
		};
	}(),
	language: (navigator.browserLanguage || navigator.language).toLowerCase()
};

//localStorage 操作
var Store = {
	saveObject: function(key, object) {
		window.localStorage[key] = JSON.stringify(object);
	},
	loadObject: function(key) {
		var objectString = window.localStorage[key];
		return objectString === undefined ? null : JSON.parse(objectString);
	},
	deleteObject: function(key) {
		window.localStorage[key] = null;
	},
	clear: function() {
		window.localStorage.clear();
	}
};

//把图片转换成base64，存放到localStorage
var getBase64Image = function(img) {
	try {
		if (!/^data:image/.test($(img).attr("src")) && window.localStorage[$(img).attr("src")] === undefined) {

			var pic_real_width, pic_real_height;
			var realimg = $("<img/>").attr("src", img.src).on("load", function() {
				pic_real_width = this.width;
				pic_real_height = this.height;
				var canvas = document.createElement('canvas');
				var ctx = canvas.getContext('2d');
				canvas.width = pic_real_width;
				canvas.height = pic_real_height;
				ctx.drawImage(this, 0, 0, pic_real_width, pic_real_height);
				var mark = $(img).attr("src");
				if (mark.indexOf("?") > -1) {
					mark = mark.substring(0, mark.indexOf("?"));
				}
				// var imgType = img.src.match(/\.(jpg|jpeg|png|gif)$/i);
				// console.info(imgType);
				// if (imgType && imgType.length) {
				// 	imgType = imgType[1].toLowerCase() == 'jpg' ? 'jpeg' : imgType[1].toLowerCase();
				// } else {
				// 	throw 'Invalid image type for canvas encoder: ' + img.src;
				// }
				window.localStorage[mark] = canvas.toDataURL();
			});
		}
	} catch (e) {
		console && console.log(e);
		return 'error';
	}
}
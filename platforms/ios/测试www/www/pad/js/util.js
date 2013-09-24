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

//下载文件
var downloadFile = function(sourceUrl, targetUrl, callback) {

	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, null);

	var fileName = sourceUrl;
	if (fileName.indexOf("?") > -1) {
		fileName = fileName.substring(0, fileName.indexOf("?"));
	}

	if (fileName.indexOf("file://") > -1) {
		var fileEntry = new Object;
		fileEntry.fullPath = sourceUrl;
		showPic(fileEntry);
	}

	fileName = fileName.substring(fileName.lastIndexOf("/") + 1, fileName.lenght);

	function gotFS(fileSystem) {
		fileSystem.root.getDirectory(targetUrl, {
			create: true,
			exclusive: false
		}, writerFile, null);
	}

	function writerFile(newFile) {
		newFile.getFile(fileName, null, showPic, function() {
			newFile.getFile(fileName, {
				create: true,
				exclusive: false
			}, gotFileEntry, null);
		});
	}

	function showPic(fileEntry) {
		//文件存在就直接显示  
		callback(fileEntry);
	}

	function gotFileEntry(fileEntry) {
		var fileTransfer = new FileTransfer();
		var uri = encodeURI(sourceUrl);
		fileTransfer.download(
			uri, fileEntry.fullPath, function(entry) {
				callback(entry);
			}, function(error) {
				console.log("下载网络图片出现错误");
			});
	}
};

function combineString(mark) {
	console.info("131 " + mark);
	var str = "";
	//var marker = store.get(mark);
	var marker = window.localStorage[mark];
	console.info(marker);
	var markers = marker.split(";");
	for (var i = 0; i < markers.length; i++) {
		//str = str + store.get(markers[i]);
		str = str + window.localStorage[markers[i]];
	}
	return str;
};

function chop(str, step) {
	if (str == null) return [];
	str = String(str);
	step = ~~step;
	return step > 0 ? str.match(new RegExp('.{1,' + step + '}', 'g')) : [str];
};


//获取字符串字节数
String.prototype.getBytesLength = function() {
	return this.replace(/[^\x00-\xff]/gi, "--").length;
};

function subStrByCnLen(str, len) {
	var cnlen = len * 2;

	var index = 0;
	var tempStr = "";

	for (i = 0; i < str.length; i++) {
		var s = str.charAt(i);
		if (index >= cnlen) {
			// return tempStr;
		} else {
			if (s.getBytesLength() > 1) {
				index += 2;
			} else {
				index += 1;
			}
			tempStr = tempStr + s;
		}
	}
	if (str.getBytesLength() > cnlen) {
		tempStr = tempStr + "..";
	}
	return tempStr;
};
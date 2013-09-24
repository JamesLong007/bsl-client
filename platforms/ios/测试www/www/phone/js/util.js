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
			console.log("开始缓存");
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
				console.log("缓存完成");
			});
		}
	} catch (e) {
		console && console.log(e);
		return 'error';
	}
}

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
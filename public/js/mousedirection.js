var direction = "",
    oldx = 0,
    mousemovemethod = function (e) {
    
        if (e.pageX < oldx) {
            direction = "left"
        } else if (e.pageX > oldx) {
            direction = "right"
        }
        
        oldx = e.pageX;
        
	}

document.addEventListener('mousemove', mousemovemethod);
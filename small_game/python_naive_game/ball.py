# -*- coding: utf-8 -*
class circle:
    
    def __init__(self,window,P1,level):
        from graphics import GraphWin,Circle
        import random
        from time import time
        self.p1=P1
        self.window=window
        self.cir=Circle(self.p1,0.4)
        self.level=level
        self.cir.setWidth(0)
       
        i=random.randrange(6,9+self.level)
        self.color=i
        if self.color==6:                 #颜色对应数字
            self.cir.setFill("red")
        if self.color==7:
            self.cir.setFill("green")
        if self.color==8:
            self.cir.setFill("black")
        if self.color==9:
            self.cir.setFill("blue")
        if self.color==10:
            self.cir.setFill("orange")
        for s in range(100):
            cirs=Circle(self.p1,0.0+s*0.004)
            if self.color==6:
                cirs.setFill("red")
            if self.color==7:
                cirs.setFill("green")
            if self.color==8:
                cirs.setFill("black")
            if self.color==9:
                cirs.setFill("blue")
            if self.color==10:
                cirs.setFill("orange")
            cirs.draw(self.window)
            empty=0                     #空循环控制时间（time间隔太大）
            while empty<=30000:
                empty=empty+1
            cirs.undraw()    
        self.cir.draw(self.window)
        self.activate=True
            
    
    def click(self,pr):
        from graphics import Circle
        import time
        pd=False       
        if self.activate==True and (pr.getX()-self.p1.getX())**2+(pr.getY()-self.p1.getY())**2<=0.24:
            
            for i in range(3):                    #点击动画
                self.cir.move(0,-0.12/3.0)
                time.sleep(0.01)
            for i in range(3):
                self.cir.move(0,0.12/3.0)
                time.sleep(0.01)
            for i in range(3):
                self.cir.move(0,-0.12/3.0)
                time.sleep(0.01)
            for i in range(3):
                self.cir.move(0,0.12/3.0)
                time.sleep(0.01)
            pd=True
        return pd
  
            
           
    def undraw(self):
        self.cir.undraw()
    def close(self):
        self.cir.undraw()
        self.activate=False
    def move(self,pr):
        self.cir.move(pr.getX()-self.p1.getX(),pr.getY()-self.p1.getY())
        self.p1.move(pr.getX()-self.p1.getX(),pr.getY()-self.p1.getY())
   
        
        
            
            
    
    
       
    
    

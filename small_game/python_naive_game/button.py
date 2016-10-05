class Button:
    from graphics import*
    def __init__(self,window,P1=Point(20,20),P2=Point(60,40),name=""):
        from graphics import*
        self.p1=P1
        self.p2=P2
        self.window=window
        self.activate=True
        self.t=Text(Point((self.p1.getX()+self.p2.getX())/2.0,(self.p1.getY()+self.p2.getY())/2.0),self.name)
    def name(self,names):

        self.t.setText(names)
    def draw(self):
        from graphics import*
        
        self.rec=Rectangle(self.p1,self.p2)
        self.rec.draw(self.window)
        self.rec.setFill("gray")
        self.t.draw(self.window)
    def click(self,pr):
        from graphics import*
        from time import*
        pd=False
        if self.activate==True:
            
            
            if pr.getX()>self.p1.getX() and pr.getX()<self.p2.getX() and pr.getY()>self.p1.getY() and pr.getY()<self.p2.getY():
                pd=True
                self.rec.setFill("blue")
                sleep(0.2)
                self.rec.setFill("gray")
        return pd
    def deactivate(self):
        self.activate=False
    def activate(self):
        self.activate=True
   
        
    

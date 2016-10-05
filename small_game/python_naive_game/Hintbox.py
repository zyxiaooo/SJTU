# -*- coding: utf-8 -*
class hintbox:
    
    def __init__(self,win,p,string):
        import graphics
        import time

        self.text=graphics.Text(p,string)
        self.win=win
    def show(self):
        import graphics
        import time

        self.text.draw(self.win)        #提示框闪烁
        time.sleep(0.25)
        self.text.undraw()
        time.sleep(0.15)
        self.text.draw(self.win)
        time.sleep(0.25)
        self.text.undraw()
        time.sleep(0.15)
        self.text.draw(self.win)
        time.sleep(0.25)
        self.text.undraw()
    def change(self,newstring):
        import graphics
        import time

        self.text.setText(newstring)

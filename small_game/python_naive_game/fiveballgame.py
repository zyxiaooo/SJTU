# -*- coding: utf-8 -*
from graphics import*
from copy import*
from ball import circle           #彩球的class
from random import*
from time import*
from button import Button
from threading import*
from Hintbox import hintbox       #提示框
import winsound
import os  
def playmusic1():                 #播放音乐的过程   
    while True:
        mp3=r"cannon rock.wav"
        winsound.PlaySound(mp3, winsound.SND_NODEFAULT)
def search1(j,i,j1,i1,ss):        #递归搜索有无移动路径:j,i为起点坐标，j1,i1为目的地坐标，ss为矩阵
    r=[]                          
    
    def search(j,i,dd):           #具体搜索过程
        dd[j][i]=1
        cirl=Circle(Point(i+0.5,j+0.5),0.2)    #在界面用小号球显示搜索过程动画
        r.append(cirl)                   
        cirl.setFill(colorstr)                 #保证小球与大球颜色相同
        cirl.setWidth(0)
        cirl.draw(win)
        if len(r)>=5:                          #最多显示六个小球
            r[0].undraw()
            del r[0]
        empty=0
        while empty<250000:                     #空循环控制时间（time间隔太大）         
            empty=empty+1  
        if dd[j][i+1]==0:                       #四个方向搜索
            if dd[j1][i1]==1:
                for items in r:                 #如果搜到了目的地则返回（并设目的地值为1）
                    items.undraw()
                return
            search(j,i+1,dd)
        if dd[j][i-1]==0:
            if dd[j1][i1]==1:
                for items in r:
                    items.undraw()
                return
            search(j,i-1,dd)
        if dd[j+1][i]==0:
            if dd[j1][i1]==1:
                for items in r:
                    items.undraw()
                return
            search(j+1,i,dd)
        if dd[j-1][i]==0:
            if dd[j1][i1]==1:
                for items in r:
                    items.undraw()
                return
            search(j-1,i,dd)
        for items in r:
            items.undraw()
            
    dd=deepcopy(ss)                             #复制原矩阵备用
    search(j,i,dd)
    
   
    if dd[j1][i1]==1:                           #搜索后若目的地为1则证明有路径通过
        return True                             #返回真
    else:
        return False                             #若不然返回假
    
def vanish(j,i,ss,color,bonus,combo,number):    #消去过程:j,i为消去位置坐标，ss为矩阵  
    if combo==0:                                #color为消去彩球颜色，bonus为分数，combo为连击次数，number为连击彩球数
        number=0
    combo1=combo
    dd=deepcopy(ss)
    
    def prevanishV(j,i,dd,color):              #消去列过程 
        s=True
        r=True                                 #从消去点查找列的同色球，并将其矩阵值改为5
        dd[j][i]=5         
        k=1
        while s==True:
            if dd[j-k][i]!=color:
                s=False
            else:
                dd[j-k][i]=5
                k=k+1
        q=1
        while r==True:
            if dd[j+q][i]!=color:
                r=False
            else:
                dd[j+q][i]=5
                q=q+1
        
        if k+q-1>=5:                           #如果同色球大于5个返回次数
            return k+q-1
        else:
            
            return 0                           #否则返回0
    def prevanishL(j,i,dd,color):              #同理消去行过程
        s=True                     
        r=True
        dd[j][i]=4                             #连续同色球位置改为4
        k=1
        while s==True:
            if dd[j][i-k]!=color:
                s=False
            else:
                dd[j][i-k]=4
                k=k+1
                
        q=1
        while r==True:
            
            if dd[j][i+q]!=color:
                r=False
            else:
                dd[j][i+q]=4
                q=q+1
        
        
        if k+q-1>=5:
            return k+q-1
        else:
            
            return 0
    sametime=False                            #判断是否有行列同时满足消除条件
    if prevanishV(j,i,dd,color)>=5:           #如果满足行消去条件
        sametime=True                         #具体消去行的球
        for q in range(1,12):
            for w in range(1,12):
                if dd[q][w]==5:
                    dd[q][w]=0
                    ss[q][w]=0
                    sleep(0.1)
                    c[(q,w)].close()
                    del(c[q,w])
                    number=number+1
                    bonus=bonus+90+number*10+combo*20 #加分
                    text4.setText(bonus)
        combo=combo+1                          #连击加1
    
    if prevanishL(j,i,dd,color)>=5:           #同理判断列
     
        if sametime==True:                  #判断是否已消去行，同时消除条件
            dd[j][i]=0
        
        for q1 in range(1,12):
            for w1 in range(1,12):
                if dd[q1][w1]==4:
                    dd[q1][w1]=0
                    ss[q1][w1]=0
                    sleep(0.1)
                    c[(q1,w1)].close()
                    del(c[(q1,w1)])
                    number=number+1
                    bonus=bonus+90+number*10+combo*20
                    text4.setText(bonus)
        combo=combo+1
    if combo1==combo:                        #如果连击中断，combo归零
        combo=0
    return ss,bonus,combo,number
def addblock(ll,ss):                          #加砖堵路，矩阵值设为-1
    judge=False
    while judge==False:
        i=randrange(1,11)
        j=randrange(1,11)
        if ss[i][j]==0:
            judge=True
            ss[i][j]=-1
            block=Rectangle(Point(j,i),Point(j+1,i+1))
            block.setFill("brown")
            block.draw(win)
            ll.append(block)
def removeblock(ll):                           #除去砖（主要用于初始化）
    for item in ll:
        item.undraw()
    
                                                       
def dealrecord(obfile,data):                   #分数记录处理系统
    s1=11                                      #s1初值大于文档行数
    ppp=False                                  #判断是否进排行榜
    alppp=False                                #辅助bollean变量防止重复操作
    datalist=[]                                #记录列表
    textlist=[]                                #text列表
    f=open(obfile,"r")                         #读取
    f.seek(0)
    for i1 in range(10):
        datalist.append(f.readline())
    for i2 in range(5):
        if data>=eval(datalist[i2]):        #如果进排行榜，插入成绩
            tsuccess=Text(Point(100,150),'''High score!!
Please enter your name!''')
            tsuccess.setFill("red")            
            tsuccess.draw(wins)             
            del datalist[4]                 
            datalist.insert(i2,data)
            del datalist[9]
            datalist.insert(i2+5,"anonymous\n") 
            s1=i2
            f.seek(0)
            ppp=True
            break
   
    for i3 in range(5):                 #打印成绩单                
        if i3!=s1:
            texta=Text(Point(140,240+i3*40),datalist[i3])
            textb=Text(Point(60,240+i3*40),datalist[i3+5])
            texta.draw(wins)
            textb.draw(wins)
            textlist.append(texta)
            textlist.append(textb)
        if i3==s1:
            texta=Text(Point(140,240+i3*40),datalist[i3])
            texta.draw(wins)
            textlist.append(texta)
            entryb=Entry(Point(60,240+i3*40),8)
            entryb.draw(wins)
            textlist.append(entryb)
            ppp=True
    notppp=True
    while ppp==True:
        pppp=wins.getMouse()
        if Bquitscore.click(pppp)==True:
            ppp=False
            name=entryb.getText()            #输入名字
            if name=="":
                name="anonymous"             #如果名字为空默认为“anonymous”
            datalist[s1]=str(data)+"\n"
            datalist[s1+5]=name+"\n"
            for item in textlist:
                item.undraw()
            f=open(obfile,"w")
            for i4 in range(10):
                f.write(str(datalist[i4]))
            f.close()
            alppp=True
            wins.close()
    while notppp==True and alppp==False:
        pppp=wins.getMouse()
        if Bquitscore.click(pppp)==True:
            if ppp==True:
                
                tsuccess.undraw()
            for item in textlist:
                item.undraw()
            notppp=False
            wins.close()
    
    
    
win=GraphWin("Five balls game",500,650)             
win.setCoords(1,15,11,1)
picture=Image(Point(8,6),"background.gif")      #背景图片
picture.draw(win)
bstart=Button(win,Point(3,12),Point(5,13))
bquit=Button(win,Point(7,12),Point(9,13))
text1=Text(Point(6,2),"五子彩球")                #标题与说明
text2=Text(Point(5,8),'''规则说明:点击彩球将同色球移动到一行或一列，
                            若每行有五个或每列有五个以上则消去，并
                            获得相应的分数。若一次移动没有消去彩球，
                            则会随机出现三个新彩球，若成功消去则此次
不会出现新彩球。
                            
                                -如果移动路线被其他彩球或砖块挡住，则不能移动
         
                                   -连续若干次成功消去彩球，会获得相应的combo加分
                    
                        -随着分数增加彩球颜色会增多，且每移动25次
                            会有一个砖块产生。所以尽量在少的步数内连
                            击更多的彩球
-在排行榜上写下你的尊姓大名 ''')       
text1.setSize(36)
text1.setStyle("bold")
text1.setTextColor("red")
text1.draw(win)
text2.draw(win)
colorstr="green"
bstart.name("start")
bquit.name("quit")
bstart.draw()
bquit.draw()
x=Thread(target=playmusic1)           #多线程播放音乐
x.setDaemon(True)                     #随主程序一起结束（否则关闭后音乐不停。。。）
x.start()

begin=False
while begin==False:
    fp=win.getMouse()
    if bstart.click(fp)==True:
        begin=True
    if bquit.click(fp)==True:
        win.close()
        os._exit(0)                     #结束程序（否则关闭后音乐还是不停。。。）
text1.undraw()                         #进入游戏界面
text2.undraw()
score=0                                #总分
step=0                                 #步数
text3=Text(Point(3,14),"Score:")       
text3.draw(win)
text4=Text(Point(5,14),score)          #显示分数
text4.draw(win)
Tstep=Text(Point(7,14),"step:")
Tstep.draw(win)
Tstepnum=Text(Point(9,14),step)        #显示步数
Tstepnum.draw(win)
Thint=hintbox(win,Point(6,11.5),"Welcome!!!")    #提示框
number=0                               #连击球数
combo=0                             #连击次数
for i in range(1,12):                #划线
    L=Line(Point(11,i),Point(1,i))
    L.setFill("orange")
    L.draw(win)
    L=Line(Point(i,11),Point(i,1))
    L.draw(win)
    L.setFill("orange")
c={}                                #记录球的位置的字典，球的索引为球的坐标             
blockgroup=[]                       #砖块组
mm=[[2,2,2,2,2,2,2,2,2,2,2,2],      #2为封边界
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,0,0,0,0,0,0,0,0,0,0,2],
    [2,2,2,2,2,2,2,2,2,2,2,2]]
mm2=deepcopy(mm)
level=0                             #等级（球的颜色数）
r=0                                 #控制随机产生球的个数
Thint.show()                           
while r<=3:                         #产生4个随机球
    i=randrange(1,12)
    j=randrange(1,12)
    if mm[j][i]==0:
        c[(j,i)]=circle(win,Point(i+0.5,j+0.5),level)
        mm[j][i]=c[j,i].color
        r=r+1
bstart.name("restart")
while True:                         #进入主循环
    pr=win.getMouse()
    for (index,t1) in c.items():    #如果点击到球
        if t1.click(pr)==True:
            item=t1
            if item.color==6:
                colorstr="red"      #上面search函数中的小球颜色
            if item.color==7:
                colorstr="green"
            if item.color==8:
                colorstr="black"
            if item.color==9:
                colorstr="blue"
            if item.color==10:
                colorstr="orange"

            
            clickBall=True          #判断是否点击球
            while clickBall==True:  
                ps=win.getMouse()    #再次点击，如果依然点击球则再次循环
                if ps.getY()<11 and ps.getX()<11 :
                    if mm[int(ps.getY())][int(ps.getX())]==6 or mm[int(ps.getY())][int(ps.getX())]==7 or mm[int(ps.getY())][int(ps.getX())]==8 or mm[int(ps.getY())][int(ps.getX())]==9 or mm[int(ps.getY())][int(ps.getX())]==10:
                        clickBall=True
                        for (index,t2) in c.items():
                            if t2.click(ps)==True:     
                                item=t2
                                if item.color==6:
                                    colorstr="red"
                                if item.color==7:
                                    colorstr="green"
                                if item.color==8:
                                    colorstr="black"
                                if item.color==9:
                                    colorstr="blue"
                                if item.color==10:
                                    colorstr="orange"

                    else:
                        clickBall=False    #如果不点击球的话则跳出循环
                if bquit.click(ps)==True:  #点击退出按钮
                    win.close()
                    os._exit(0)
                if bstart.click(ps)==True: #点击重新开始按钮
                    mm=deepcopy(mm2)        #初始化过程开始
                    for (index,item) in c.items():
                        item.close()
                    c={}
                    level=0
                    score=0
                    combo=0
                    step=0
                    Tstepnum.setText(step)
                    text4.setText(score)
                    Thint.change("welcome")
                    r=0
                    removeblock(blockgroup)
                    
                    blockgroup=[]
                    while r<=3:
                        i=randrange(1,12)
                        j=randrange(1,12)
                        if mm[j][i]==0:
                            c[(j,i)]=circle(win,Point(i+0.5,j+0.5),level)
                            mm[j][i]=c[j,i].color
                            r=r+1
                    r=0                     #初始化结束
              #到此处应该是点击了一个球和一个空格子      
            if ps.getY()<11 and search1(int(item.p1.getY()),int(item.p1.getX()),int(ps.getY()),int(ps.getX()),mm)==True:
                step=step+1             #上面一行是开始搜索路径，如果真则继续。此行是步数加一 
                Tstepnum.setText(step)  #显示步数
                mm[int(item.p1.getY())][int(item.p1.getX())]=0 #原位置矩阵设为0（无球）
                del(c[(int(item.p1.getY()),int(item.p1.getX()))])#删除c中原位置的球
                item.move(Point(int(ps.getX())+0.5,int(ps.getY())+0.5))#将球移动到点击位置
                c[(int(item.p1.getY()),int(item.p1.getX()))]=item #c中在点击位置添加球
                mm[int(item.p1.getY())][int(item.p1.getX())]=item.color#矩阵中相应位置改成相应颜色球对应数字
                tt=deepcopy(vanish(int(item.p1.getY()),int(item.p1.getX()),mm,item.color,score,combo,number))#判断是否有可消去的球，并执行相应操作，函数部分已注。
                mm=tt[0]                           #mm赋值为操作后的新的矩阵
                if score<8000 and tt[1]>=8000: #分数第一次上8000则升级（多一个颜色）
                    level=level+1
                    Thint.change("Level up!! New color!!")
                    Thint.show()
                if score<20000 and tt[1]>=20000: #分数第一次上20000则升级（再多一种颜色）
                    level=level+1
                    Thint.change("Level up!! New color!!")
                    Thint.show()
                    
               
                score=tt[1] #总分，连击次数，连击球数的赋值
                combo=tt[2]
                number=tt[3]
                if combo==3: #提示框连击提醒
                    Thint.change("Combo*3 Wonderful!!!!")
                    Thint.show()
                if combo==4:
                    Thint.change("Combo*4 Excellent!!!!")
                    Thint.show()
                if combo>=5:
                    Thint.change("Combo Master!!!!")
                    Thint.show()
                if step % 25 == 0:
                    addblock(blockgroup,mm)
                    Thint.change("Block added,hurry up!!!")
                    Thint.show()
                r=0         #如果没有消去球则随机新产生三个球
                while r<=2 and combo==0 and len(c)<100-len(blockgroup):
                    i=randrange(1,12)
                    j=randrange(1,12)
                    if mm[j][i]==0:
                        c[(j,i)]=circle(win,Point(i+0.5,j+0.5),level)
                        mm[j][i]=c[j,i].color
                        tt=deepcopy(vanish(j,i,mm,c[(j,i)].color,score,combo,number))
                        mm=tt[0]
                        if score<8000 and tt[1]>=8000: #这是新产生的球位置正好能消去后亦可升级
                            level=level+1              #（接上）否则这种情况升级不了。。。
                            Thint.change("Level up!! New color!!")
                            Thint.show()                           
                        if score<20000 and tt[1]>=20000:
                            level=level+1
                            Thint.change("Level up!! New color!!")
                            Thint.show()
                            
                        score=tt[1]
                        combo=tt[2]
                        number=tt[3]
                        if combo==3:
                            Thint.change("Combo*3 Wonderful!!!!")
                            Thint.show()
                        if combo==4:
                            Thint.change("Combo*4 Excellent!!!!")
                            Thint.show()
                        if combo>=5:
                            Thint.change("Combo Master!!!!")
                            Thint.show()
                        r=r+1
                r=0
      
    if bstart.click(pr)==True: #点击开始按钮
        mm=deepcopy(mm2)
        for (index,item) in c.items():
            item.close()
        c={}
        level=0
        score=0
        combo=0
        text4.setText(score)
        r=0
        step=0
        Tstepnum.setText(step)
        Thint.change("Welcome")
        removeblock(blockgroup)
        blockgroup=[]
        while r<=3:
            i=randrange(1,12)
            j=randrange(1,12)
            if mm[j][i]==0:
                c[(j,i)]=circle(win,Point(i+0.5,j+0.5),level)
                mm[j][i]=c[j,i].color
                r=r+1
        r=0
        
    if bquit.click(pr)==True: #点击退出按钮
        win.close()
        os._exit(0)
    if len(c)==100-len(blockgroup):#当球充满所有格子，游戏结束
        wins=GraphWin("Result",200,500)#弹出排行榜界面
        Tscore=Text(Point(80,100),"your score is %d"%score)
        Tscore.draw(wins)
        Bquitscore=Button(wins,Point(80,460),Point(120,490))
        Bquitscore.name("OK")
        Bquitscore.draw()
        dealrecord("record.txt",score) #处理排行系统
        mm=deepcopy(mm2)               #初始化开始
        for (index,item) in c.items():
            item.close()
        c={}
        level=0
        score=0
        combo=0
        step=0
        Tstepnum.setText(step)
        text4.setText(score)
        Thint.change("Welcome")
        r=0
        removeblock(blockgroup)
        blockgroup=[]
        while r<=3:                  
            i=randrange(1,12)
            j=randrange(1,12)
            if mm[j][i]==0:
                c[(j,i)]=circle(win,Point(i+0.5,j+0.5),level)
                mm[j][i]=c[j,i].color
                r=r+1
        r=0                             #结束
        
    



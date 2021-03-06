## Make sure you're working from [dropboxfolder]/code
source("settings.R")
source('funs.R')
source('testfuns.R')
source('dualPathSvd2.R')
library(RColorBrewer)

outputdir = "output" # Ryan

########################################################
#### Generate p-values and simulation quantities #######
########################################################

  nsim = 500
  n = 60
  sigma = 1
  lev1= 0
  lev2= 2
 # lev2list=c(0,0.5,1,1.5,2)
  lev2list = c(0,1,2)*.5
  numsteps=1
#  spike   = introexample(testtype = "spike", nsim=nsim,sigma=sigma,lev1=lev1,lev2=lev2,lev2list=lev2list,numsteps=numsteps,verbose=T)
#  segment = introexample(testtype = "segment", nsim=nsim,sigma=sigma,lev1=lev1,lev2=lev2,lev2list=lev2list,numsteps=numsteps,verbose=T)
  #save(file = file.path(outputdir,"onejump-example-finersignal.Rdata"), list = c("lev1","lev2list","nsim","spike","segment","proportions0", "proportions1"))
  #save(file = file.path(outputdir,"onejump-example.Rdata"), list = c("lev1","lev2list","nsim","spike","segment","proportions0", "proportions1"))

###########################################
#### plotting QQ plots for p-values #######
###########################################
  load(file.path(outputdir,"onejump-example.Rdata"))

    set.seed(0)
    sigma = 1
    y0    = onejump.y(returnbeta=F,lev1=0,lev2=2,sigma=sigma,n=60)
    beta0 = lapply(c(0:2), function(lev2) onejump.y(returnbeta=T,lev1=0,lev2=lev2,sigma=sigma,n=60))
    beta0.middle = onejump.y(returnbeta=T,lev1=0,lev2=1,sigma=sigma,n=60)
    beta0.top = onejump.y(returnbeta=T,lev1=0,lev2=2,sigma=sigma,n=60)
    x.contrasts = c(1:60)
    v.spike = c(rep(NA,29),.5*c(-1,+1)-2, rep(NA,29))
    v.segment = c(.3*rep(-0.7,30)-2 , .3*rep(+0.7,30)-2 )

    xlab = "Location"
    w = 5; h = 5
    pch = 16; lwd = 2
    pcol = "gray50"
    ylim = c(-3,5)
    mar = c(4.5,4.5,0.5,0.5)
    xlim = c(0,70)

    xticks = c(0,2,4,6)*10
    let = c("A","B")
    ltys.sig = c(2,2,1)
    lwd.sig = 2
    pch.dat = 16
    pcol.dat = "grey50"
    pch.contrast = 17
    lty.contrast = 2
    lcol.sig = 'red'
    pcol.spike=3
    pcol.segment=4
    pcols.delta =   pcols.oneoff = brewer.pal(n=3,name="Set2")
    pch.spike = 15
    pch.segment = 17
    cex.contrast = 1.2

  ##################################
  ## Example of data and contrast ##
  ##################################
  pdf("output/onejump-example-data-and-contrast.pdf", width=5,height=5)   

    par(mar=c(4.1,3.1,3.1,1.1))
      plot(y0, ylim = ylim,axes=F, xlim=xlim, xlab = xlab, ylab = "", pch=pch, col=pcol);
      axis(1, at = xticks, labels = xticks); axis(2)
      for(ii in 1:3) lines(beta0[[ii]],col="red",lty=ltys.sig[ii], lwd=lwd.sig)
      for(ii in 0:2) text(x=65,y=ii, label = bquote(delta==.(ii)))
      points(v.spike~x.contrasts, pch = pch.spike, col = 3)
      points(v.segment~x.contrasts, pch = pch.segment, col = 4) 
      abline(h = mean(v.segment,na.rm=T), col = 'lightgrey')
      legend("topleft", pch=c(pch.dat,NA,pch.spike,pch.segment), 
             lty=c(NA,1,NA,NA), lwd=c(NA,2,NA,NA),
             col = c(pcol.dat, lcol.sig, pcol.spike,pcol.segment),
             pt.cex = c(cex.contrast, NA, cex.contrast, cex.contrast),
             legend=c("Data", "Mean","Spike contrast", "Segment contrast"))
     title(main=expression("Data example"))
  graphics.off()

  ##########################################
  ## QQ plot of correct location p-values ##
  ##########################################
  contrast.type = c("Spike", "Segment")
  dat = list(spike,segment)
  for(jj in 1:2){
    pdf(paste0("output/onejump-example-qqplot-",tolower(contrast.type[jj]),".pdf"), width=5,height=5)
      mydat = dat[[jj]]
      unif.p = runif(10000,0,1)
      for(ii in 1:3){
        if(ii!=1) par(new=T) 
#        qqplot(y = mydat$pvals.correctlist[[ii]],
#               x = unif.p,
#               axes=F, xlab="", ylab="", col = pcols.delta[ii])
        a = qqplot(x=unif.p, y=mydat$pvals.correctlist[[ii]], plot.it=FALSE)
        myfun = (if(ii==1) plot else points)
        myfun(x=a$y, y=a$x, axes=F, xlab="", ylab="", col = pcols.delta[ii], pch=16)
      }
      axis(2);axis(1)
      mtext("Expected",1,padj=4)
      mtext("Observed",2,padj=-4)
      title(main = bquote(.(contrast.type[jj])~test~p-values))
      if(jj==1){
        legend("bottomright", col = pcols.delta, 
               lty = 1, lwd = 5, 
               legend = sapply(c(bquote(delta==0),
                                 bquote(delta==1),
                                 bquote(delta==2)), as.expression) )
      }
     graphics.off()    
   }
  ########################################
  ## QQ plot of one-off p-values right  ##
  ########################################
  contrast.type = c("Segment", "Spike")
  dat = list(segment,spike)
  pdf(file.path(outputdir,"onejump-example-qqplot-oneoff.pdf"), width=5,height=5)

  unif.p = runif(10000,0,1)
  for(ii in 1:2){
    if(ii==2) par(new=T)
    mydat = dat[[ii]]
    a = qqplot(x=unif.p, y=mydat$pvals.oneoff, plot.it=FALSE)
    myfun = (if(ii==1) plot else points)
    myfun(x=a$y, y=a$x,            axes=F, xlab="", ylab="", col = pcols.oneoff[ii], pch=16)
  }
  axis(2);axis(1)
  mtext("Expected",1,padj=4); mtext("Observed",2,padj=-4)
  legend("bottomright", col = pcols.oneoff, 
         lty = 1, lwd = 5, 
         legend = sapply(c(bquote(Segment~test),
                           bquote(Spike~test)), as.expression))
  title(main = bquote(atop("P-values at one-off locations", (delta==2))))

  graphics.off()



#########################################################
#### plotting p-value densities with ggplot (old) #######
#########################################################
##require(ggplot2)
#require(plyr)
##require(grid)
##source("http://peterhaschke.com/Code/multiplot.R")


#  load(file.path(outputdir,"onejump-example.Rdata"))
#  pdf("output/onejump-example.pdf", width=20,height=5)
#    cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")[c(2,3,8,4,6)]
#   
#    # LEFT figure
#      set.seed(0)
#      sigma = 1
#      y0    = onejump.y(returnbeta=F,lev1=0,lev2=1,sigma=sigma,n=60)
#      beta0.bottom = onejump.y(returnbeta=T,lev1=0,lev2=0,sigma=sigma,n=60)
#      beta0.middle = onejump.y(returnbeta=T,lev1=0,lev2=1,sigma=sigma,n=60)
#      beta0.top = onejump.y(returnbeta=T,lev1=0,lev2=2,sigma=sigma,n=60)
#      x0 = c(1:60)
#      x0.spike = c(rep(NA,29),.5*c(-1,+1)-2, rep(NA,29))
#      x0.segment = c(.3*rep(-0.7,30)-2 , .3*rep(+0.7,30)-2 )
#      
#      dt = data.frame(x0, y0, beta0.bottom, beta0.middle, beta0.top)
#      a1 <- ggplot(dt, aes(x=x0, y=y0, colour="x"))
#      a1 <- a1 + geom_point()
#      a1 <- a1 + geom_point(aes(x=x0, y = x0.segment,colour="d"), size=3, linetype="dashed") +
#                 geom_point(aes(x=x0, y = x0.spike, colour="e"), size=3)            
#      a1 <- a1 + geom_line(aes(x=x0, y = beta0.bottom, colour="a"), size=1.2, linetype="dashed") + 
#                 geom_line(aes(x=x0, y = beta0.middle, colour="b"), col = 'red', size=1.2, linetype="dotted") +
#                 geom_line(aes(x=x0, y = beta0.top   , colour="c"), col = 'red', size=1.2)


#      a1 <- a1 + scale_y_continuous(breaks=c(0:5),labels=c(0:5))                                  
#      a1 <- a1 + xlab("Coordinates") + ylab("y")
#      a1 <- a1 + annotate("text", x=c(65,65,65),y=c(0,1,2), label = c("delta==1","delta==2","delta==3"),parse = T,size=3,fontface = 'plain')
#   #  a1 <- a1 + scale_fill_identity(name = 'the fill', guide = 'legend',labels = c('m1'))
#      a1 <- a1 + scale_x_continuous(limits = c(0, 90))
#      a1 <- a1 + ggtitle("Data and \n Underlying Signal") + 
#                 theme(plot.title = element_text(lineheight=.8, face="bold"))
#     # a1 <- a1 + theme(plot.margin = unit(c(1,2,0,0), "cm"))  
#      a1 <- a1 + scale_fill_identity(guide = "legend")
#      a1 <- a1 + scale_colour_manual(name = "",
#                                     values=c("a"="red","x" ="black","d"="green","e"="blue"),
#                                     labels=c("a"="Signal","x"="Data","d"="Spike","e"="Segment"))
#      a1 <- a1 + theme(legend.position = c(0.85, 0.85), legend.background = element_rect(fill = "grey90", size = 1))

######################
#### 2nd from left ###
######################
#      my.data <- as.data.frame(rbind(cbind(spike$pvals.correctlist[[3]],1),
#                                     cbind(spike$pvals.correctlist[[2]],2),
#                                     cbind(spike$pvals.correctlist[[1]],3)))
#      colors <- cbPalette[1:3]
#      labs <- expression(delta==2,delta==1,delta==0)
#      
#      my.data$V2=as.factor(my.data$V2)
#        
#      res <- dlply(my.data, .(V2), function(x) density(x$V1))
#      dd <- ldply(res, function(z){
#                          data.frame(Values = z[["x"]], 
#                                     V1_density = z[["y"]])
#      })
#      
#      poffset.x = 0.1 # adapt 0.1 as needed
#      dd$Values = dd$Values + rep(c(0,1,2)*poffset.x,each=512)
#      dd$offest=-(as.numeric(dd$V2)-1)*1# adapt the 1 value as you need
#      dd$V1_density_offest = dd$V1_density+dd$offest
#      
#      dd.a2 <- dd

#      a2 <- ggplot(dd.a2) 
#   
#      a2 <- a2 + geom_line( aes(Values, V1_density_offest, color=V2), size = 1.5)
#      a2 <- a2 + geom_ribbon(aes(Values, ymin=offest,ymax=V1_density_offest, fill=V2),alpha=0.3)
#      a2 <- a2 + scale_color_manual(values=colors,guide=FALSE)
#      a2 <- a2 + scale_x_continuous(breaks=NULL) 
#      a2 <- a2 + scale_y_continuous(breaks=c(0:5),labels=c(0:5))
#      a2 <- a2 + xlab("p-values") + ylab("Fitted Density")
#      a2 <- a2 + scale_fill_manual(name="Signal Sizes",
#                                 values=colors,
#                                 labels=labs)
#      a2 <- a2 + ggtitle("Spike Test p-value Distribution \n Correct Location") + 
#               theme(plot.title = element_text(lineheight=.8, face="bold"))
#      a2 <- a2 + theme(legend.position = c(0.85, 0.85), legend.background = element_rect(fill = "grey90", size = 1))


#######################
### 3rd from left  ####
#######################

#      poffset.x = 0.1 # adapt 0.1 as needed
#      my.data <- as.data.frame(rbind(cbind(segment$pvals.correctlist[[3]],1),
#                                     cbind(segment$pvals.correctlist[[2]],2),
#                                     cbind(segment$pvals.correctlist[[1]],3)))
#      a5.colors <- cbPalette[1:3]
#      labs <- expression(delta==2,delta==1,delta==0)
#      
#      my.data$V2=as.factor(my.data$V2)
#        
#      res <- dlply(my.data, .(V2), function(x) density(x$V1,from=-0.04,to=1.04, bw=0.01))
#      dd <- ldply(res, function(z){
#                          data.frame(Values = z[["x"]], 
#                                     V1_density = z[["y"]])
#      })
#        
#      poffset.x = 0.1 # adapt 0.1 as needed
#      dd$Values = dd$Values + rep(c(0,1,2)*poffset.x,each=512)
#      dd$offest=-(as.numeric(dd$V2)-1)*5# adapt the 1 value as you need
#      dd$V1_density_offest = dd$V1_density+dd$offest
#      yticks = seq(from=0,to=50,by=10)
#      
#      dd.a5<- dd

#      a5 <- ggplot(dd.a5) 
#      a5 <- a5 + geom_line( aes(Values, V1_density_offest, color=V2), size = 1.5)
#      a5 <- a5 + geom_ribbon(aes(Values, ymin=offest,ymax=V1_density_offest, fill=V2),alpha=0.3)
#      a5 <- a5 + scale_color_manual(values=a5.colors,guide=FALSE)
#      a5 <- a5 + scale_x_continuous(breaks=NULL) 
#      a5 <- a5 + scale_y_continuous(breaks=yticks,yticks)
#      a5 <- a5 + xlab("p-values") + ylab("Fitted Density")
#      a5 <- a5 + scale_fill_manual(name="Signal Sizes",
#                                 values=colors,
#                                 labels=labs)
#      a5 <- a5 + ggtitle("Segment Test p-value Distribution \n Correct Location") + 
#               theme(plot.title = element_text(lineheight=.8, face="bold"))  
#      a5 <- a5 + theme(legend.position = c(0.85, 0.85), legend.background = element_rect(fill = "grey90", size = 1))
#      #multiplot(a1, a2, a5, layout = matrix(c(1:3),nrow=1,byrow=T), cols=3) 

#      
##################
#### Far right ###
##################

#      my.data <- as.data.frame(rbind(cbind(segment$pvals.oneoff,1),
#                                cbind(spike$pvals.oneoff,2)))
#      a4.colors <- cbPalette[1:2]
#      labs <- expression(Segment~test~p~values, Spike~Test~p~values)
#      
#      my.data$V2=as.factor(my.data$V2)
#        
#      res <- dlply(my.data, .(V2), function(x) density(x$V1, bw="ucv",from=-0.01,to=1.01))
#      dd <- ldply(res, function(z){
#                          data.frame(Values = z[["x"]], 
#                                     V1_density = z[["y"]])
#      })
#      
#      poffset.x = 0.075 # adapt 0.1 as needed
#      dd$Values = dd$Values + rep(c(0,1)*poffset.x,each=512)
#      myfactor = 2.5
#      dd$offest=-(as.numeric(dd$V2)-1)*myfactor# adapt the 1 value as you need
#      dd$V1_density_offest = dd$V1_density+dd$offest
#      dd.a4<-dd

#      a4 <- ggplot(dd.a4) 
#   
#      a4 <- a4 + geom_line( aes(Values, V1_density_offest, color=V2), size = 1.5)
#      a4 <- a4 + geom_ribbon(aes(Values, ymin=offest,ymax=V1_density_offest, fill=V2),alpha=0.3)
#      a4 <- a4 + scale_color_manual(values=a4.colors,guide=FALSE)
#      a4 <- a4 + scale_x_continuous(breaks=NULL) 
#      a4 <- a4 + scale_y_continuous(breaks=c(0:5)*10,labels=c(0:5)*10)
#      a4 <- a4 + xlab("p-values") + ylab("Fitted Density")
#      a4 <- a4+ scale_fill_manual(name="Signal Sizes",
#                                 values=colors,
#                                 labels=labs)
#      a4 <- a4 + ggtitle("Spike Test p-value Distribution \n One-off Location") + 
#                 theme(plot.title = element_text(lineheight=.8, face="bold"))
#      a4 <- a4 + theme(legend.position = c(0.65, 0.85), legend.background = element_rect(fill = "grey90", size = 1))    

#      multiplot(a1, a2, a5,  a4, layout = matrix(c(1,2,3,4),nrow=1,byrow=T), cols=4) 

#  dev.off()


#######################################################################################  
#### Seeing how frequently FL catches the correct jump location in one-jump example ###
#######################################################################################
#  # Generate Data
#  lev1=0
#  n=60
#  sigma=1
#  nsim=10000
#  gaps = 0:2
#  locations = matrix(ncol = length(gaps), nrow = nsim)
#  for(gapsize in gaps){
#    cat("\r", gapsize, "of", gaps )
#    lev2 = lev1 + gapsize
#    cat("\n","a")
#    for(jj in 1:nsim){
#      cat("\r", jj, "of", nsim )
#      y0 = onejump.y(returnbeta=F,lev1=lev1,lev2=lev2,sigma=sigma,n=n)
#      f = dualpathSvd2(y0,D=dual1d_Dmat(length(y0)),maxsteps=1)
#      locations[jj,gapsize+1] = f$pathobj$B[1]
#    }
#    cat("\n","\n")
#  }
#  cat("\n","\n")
#  save(file=file.path(outputdir, "onejump-freq.Rdata"), list = c("locations","gaps","nsim","sigma","n","lev1"))

#  # Plot it
#  load(file=file.path(outputdir, "onejump-freq.Rdata"))
#  cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")[c(2,3,8,4,6)]
#  densities = list()
#  for(jj in 1:length(gaps)){
#    densities[[jj]] = density(locations[,jj])
#  }
#  plot(densities[[length(gaps)]],col='white')
#  for(jj in 1:length(gaps)){
#    lines(densities[[jj]],col=cbPalette[jj])
#  }

#  # calculate what we want
#  load(file=file.path(outputdir, "onejump-freq.Rdata"))
#  sum(locations[,1]==30)/nsim
#  sum(locations[,2]==30)/nsim
#  sum(locations[,3]==30)/nsim


#Projet Simulation et Copules

#Vous trouverez dans un 1er temps le code pour l'affichage des courbes en 3 dimensions.
#Et ensuite l ensemble du script R de notre projet.

h = function
(x, y)
{
  return(1 + log(x + y) * 2 * x)
}

#Graphe de h
persp3d(h,
        xlim=c(0, 2),
        ylim=c(0, 3),
        main="fonction h",
        ylab="y",
        xlab="x")


# pour la fonction persp3d
require("rgl")
# pour la fonction quad2d
require("pracma")

#install.packages("rgl")

# nombres totales de simulations
n = 1000
# bornes de l'espace de d�finition de X
inf_x = 0
sup_x = 2
# bornes de l'espace de d�finition de Y
inf_y = 0
sup_y = 3
# En regardant la fonction dans persp3d, on peut voir que h est � valeur dans [0, 8]
inf_v = 0
sup_v = 8

H = quad2d(h, inf_x, sup_x, inf_y, sup_y)
paste("Vraie valeur de l'int�grale de h : ", H)


ux = runif(n, inf_x, sup_x)
uy = runif(n, inf_y, sup_y)

v = runif(n, inf_v, sup_v)

# M�thode A
# Marche bien mais on veut pouvoir afficher la convergence
#Sn = 1/n * sum(v <= h(ux, uy))
#I = Sn * ((sup_x-inf_x)*(sup_y-inf_y)*(sup_v-inf_v))
#paste("valeur de l'int�grale estim� par la m�thode 1 : ", I)

# M�thode B
keeped_values = v <= h(ux, uy) * 1
Sn_array1 = 1/(1:n) * cumsum(keeped_values) * ((sup_x-inf_x)*(sup_y-inf_y)*(sup_v-inf_v))
Sn1 = 1/n * sum(keeped_values) * ((sup_x-inf_x)*(sup_y-inf_y)*(sup_v-inf_v))
biais1 = mean(Sn_array1[n]) - H
variance1 = var(Sn_array1 - H)



x = runif(n, inf_x, sup_x)
y = runif(n, inf_y, sup_y)

Sn_array2 = (sup_x-inf_x) * (sup_y-inf_y) * cumsum(h(x, y))/(1:n)
Sn2 =  1/n * (sup_x-inf_x) * (sup_y-inf_y) * sum(h(x, y))
biais2 = mean(Sn_array2[n]) - H
variance2 = var(Sn_array2 - H)


# On approxime l'int�gral de f(x) par l'esperance de f(u) avec u une uniforme
# sur le support de x (si x d�fini sur [0, 3] alors u uniforme sur [0, 3])
# On applique la m�thode des variables antith�tiques : � chaque uniforme u, 
# on calcule l'esperance de 1/2 * (f(u) + f(sup(X) - u))
# pour l'exemple pr�cedent, cel� donne : 1/2 * (f(u) + f(3 - u))
# -> l'avantage principale est d'am�liorer la vitesse de convergence :
# -> on a deux nouvelles observations (u et 1-u) � chaque nouvelle simulation de u 
# -> c'est la m�thode des variables antith�tiques
x = runif(n, inf_x, sup_x)
y = runif(n, inf_y, sup_y)

Sn_array21 = (sup_x-inf_x) * (sup_y-inf_y) * cumsum(h(x, y) + h(sup_x - x, sup_y - y))/(2*(1:n))
Sn21 =  1/n * (sup_x-inf_x) * (sup_y-inf_y) * sum(1/2 * (h(x, y) + h(sup_x - x, sup_y - y)))
biais21 = mean(Sn_array21[n]) - H
variance21 = var(Sn_array21 - H)


fx = function(x)
{
  return((0.2+0.3*x)*(x>=0 && x<=2))
}

fy = function(y)
{
  return((2/15+ 2/15*y)*(x>=0 && x<=3))
}

# on v�rifie que les int�grales sur leurs supports respectifs
# valent 1
quad(fx, 0, 2)
quad(fy, 0, 3)


Fx = function(x)
{
  return((0.2*x+(0.15*x^2)))
}

Fy = function(y)
{
  return(2/15*x+ (1/30*x^2))
}


Fx_inv = function(x)
{
  return(sqrt(20/3 * x + 4/9) - 2/3)
}

Fy_inv = function(y)
{
  return(sqrt(15*y + 1) - 1)
}


#u = runif(n, inf_v, sup_v)
u = runif(n, 0, 1)
X = Fx_inv(u)
Y = Fy_inv(u)
Sn_array3 = 1/(1:n) * cumsum(h(X, Y)/(fx(X)*fy(Y)))
Sn3 = 1/n * sum(h(X, Y)/(fx(X)*fy(Y)))
biais3 = mean(Sn_array3[n]) - H
variance3 = var(Sn_array3 - H)


franck=function(u,v) {
  teta=0.55
  v=1-v
  return( (-teta*exp(-teta*u)*exp(-teta*v)*(exp(-teta)-1))/(((exp(-teta)-1)+(exp(-teta*u)-1)*(exp(-teta*v)-1))^2))}


h_copule=function(x,y) { fx(x)*fy(y)*franck(Fx(x),Fy(y))}

u = runif(n, 0, 1)
v=  runif(n, 0, 1)
X = Fx_inv(u)
Y = Fy_inv(v)

Sn_array4 = 1/(1:n) * cumsum(h(X,Y)/(h_copule(X,Y)))
Sn4 = 1/n * sum(h(X,Y)/h_copule(X,Y))
biais4 = mean(Sn_array3[n]) - H
variance4 = var(Sn_array3 - H)
# "Vrai valeur de l'int�grale de h
print(paste("Vraie valeur de l'int�grale de h : ", H),quote=FALSE)
# On affiche les r�sultat des approximations
print(paste("M�thode 1:"),quote=FALSE)
print(paste("Valeur de l'int�grale de h : ", Sn1,"biais: ",biais1, " variance", variance1 ),quote=FALSE) 
print(paste("M�thode 2:"),quote=FALSE)
print(paste("valeur de l'int�grale de h estim� par la m�thode 2 : ", Sn2,"biais: ",biais2, " variance", variance2),quote=FALSE )
print(paste("M�thode 2.1:"),quote=FALSE)
print(paste("valeur de l'int�grale de h estim� par la m�thode 2.1 : ", Sn21,"biais: ", biais21, " variance", variance21),quote=FALSE )
print(paste("M�thode 3:"),quote=FALSE)
print(paste("valeur de l'int�grale de h estim� par la m�thode 3 : ", Sn3,"biais: ", biais3, " variance", variance3),quote=FALSE )
print(paste("M�thode 4:"),quote=FALSE)
print(paste("valeur de l'int�grale de h estim� par la m�thode 4 : ", Sn4,"biais: ", biais4, " variance", variance4),quote=FALSE )


# On affiche le graph des 5 estimateurs afin d'�tudier
# la vitesse de convergence vers la "vrai valeur"
plot(Sn_array1,
     col="gray0",
     type="l",
     ylim=c(10,20),
     #xlim=x(100, n),
     main="Vitesse de convergence",
     xlab="Nombres de simulations",
     ylab="Int�grale estim�e")
abline(H, 0)
lines(Sn_array2,type="l", col="blue")
lines(Sn_array21, col="yellow")
lines(Sn_array3, col="green")
lines(Sn_array4, col="purple")




legend(400, 12.8,
       legend=c("M�thode des Volumes",
                "M�thode de Monte Carlo",
                "M�thode des Variables Antith�tiques",
                "M�thode de la densit� jointe",
                "M�thode des copules"),
       col=c("gray0",
             "blue",
             "yellow",
             "green",
             "purple"),
       lwd=4,
       cex=0.8)
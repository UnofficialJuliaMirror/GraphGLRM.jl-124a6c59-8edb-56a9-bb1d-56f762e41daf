using GraphGLRM, LowRankModels
using Base.Test

# write your own tests here

#Create a true low-rank model
Xtrue = randn(100,10)
Ytrue = randn(10, 60)
A = Xtrue*Ytrue + 0.01*randn(100,60)

#
U, S, Vt = svd(A)
#Try a rank-10 model
Xsvd = U[:,1:10]*sqrt(Diagonal(S[1:10]))
Ysvd = sqrt(Diagonal(S[1:10]))*Vt'[1:10,:]
XYsvd = Xsvd*Ysvd

#Test that the results from LowRankModels are approximately equal to GraphGLRM
glrm_quad = GLRM(A, QuadLoss(), QuadReg(1.), QuadReg(1.), 5)
gg = GGLRM(A, QuadLoss(), QuadReg(1.), QuadReg(1.), 5)
fit!(gg); fit!(glrm_quad)
ggobj = whole_objective(gg, gg.X'*gg.Y)
glrmobj = whole_objective(gg, glrm_quad.X'*glrm_quad.Y)
@test_approx_eq_eps(ggobj, glrmobj, 0.1*length(A))

#Try for a different loss function and regularizers
glrm_hquad = GLRM(A, HuberLoss(), OneReg(1.), OneReg(1.), 5)
ggh = GGLRM(A, HuberLoss(), OneReg(1.), OneReg(1.), 5)
fit!(ggh); fit!(glrm_hquad)
gghobj = whole_objective(ggh, ggh.X'*ggh.Y)
glrmhobj = whole_objective(ggh, glrm_hquad.X'*glrm_hquad.Y)
@test_approx_eq_eps(gghobj, glrmhobj, 0.1*length(A))

#Graph regularizer
A1 = randn(6,2) * diagm([128, 16])
A2 = 2*A1 + randn(6,2)
A = [A1 A2]
A /= vecnorm(A)/√(8)
ig = IndexGraph(1:4, [(1,3),(2,4)])
GRG = GGLRM(A, QuadLoss(), QuadReg(0.02), GraphQuadReg(ig, 2., 0.01), 2)
fit!(GRG)

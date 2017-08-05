SUBROUTINE compute_potential( t_size, w_t, F_xs, F_ys, F_zs, &
                              density, potential )
  !
  USE m_constants, ONLY : PI
  USE m_LF3d, ONLY : NN => LF3d_NN, &
                     Npoints => LF3d_Npoints, &
                     lin2xyz => LF3d_lin2xyz
  IMPLICIT NONE 
  INTEGER :: t_size
  REAL(8) :: w_t(t_size)
  REAL(8) :: F_xs(t_size,NN(1),NN(1))
  REAL(8) :: F_ys(t_size,NN(2),NN(2))
  REAL(8) :: F_zs(t_size,NN(3),NN(3))
  REAL(8) :: density(NN(1),NN(2),NN(3))
  REAL(8) :: potential(Npoints)
  !
  INTEGER :: i_t, a, b, g, aa, bb, gg, ip, ipp
  REAL(8), ALLOCATABLE :: Tmatrix(:,:,:)
  
  ALLOCATE( Tmatrix(NN(1),NN(2),NN(3)) )
  Tmatrix = 0.d0

  potential(:) = 0.d0

  DO i_t = 1,t_size

    DO gg = 1,NN(3)
      Tmatrix(:,:,gg) = matmul( F_xs(i_t,:,:), density(:,:,gg) )
      Tmatrix(:,:,gg) = matmul( Tmatrix(:,:,gg), F_ys(i_t,:,:) )
    ENDDO 

    CALL transpose_yz( NN, Tmatrix )

    DO bb = 1,NN(2)
      Tmatrix(:,:,bb) = matmul( Tmatrix(:,:,bb), F_zs(i_t,:,:) )
    ENDDO 

    DO ip = 1,Npoints
      a = lin2xyz(1,ip)
      b = lin2xyz(2,ip)
      g = lin2xyz(3,ip)
      potential(ip) = potential(ip) + w_t(i_t)*Tmatrix(a,b,g)*2.d0/sqrt(PI)
    ENDDO 

  ENDDO 


END SUBROUTINE 


SUBROUTINE transpose_yz( NN, T )
  IMPLICIT NONE 
  INTEGER :: NN(3)
  REAL(8) :: T(NN(1),NN(2),NN(3))
  INTEGER :: aa, bb, gg
  REAL(8) :: t1, t2

  DO gg = 1,NN(3)
  DO bb = 1,NN(2)
  DO aa = 1,NN(1)
    t1 = T(aa,bb,gg)
    t2 = T(aa,gg,bb)
    T(aa,bb,gg) = t1
    T(aa,gg,bb) = t2
  ENDDO 
  ENDDO 
  ENDDO 

END SUBROUTINE 

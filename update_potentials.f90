SUBROUTINE update_potentials()

  USE m_LF3d, ONLY : Npoints => LF3d_Npoints, &
                     LF3d_TYPE, LF3d_PERIODIC
  USE m_hamiltonian, ONLY : Rhoe, V_Hartree, V_xc

  IMPLICIT NONE 
  REAL(8), ALLOCATABLE :: epsxc(:), depsxc(:)
  
  ALLOCATE( epsxc(Npoints) )
  ALLOCATE( depsxc(Npoints) )

  IF ( LF3d_TYPE == LF3d_PERIODIC ) THEN
    CALL Poisson_solve_fft( Rhoe, V_Hartree )
  ELSE 
    CALL Poisson_solve_pcg( Rhoe, V_Hartree )
    !CALL Poisson_solve_fft_MT( Rhoe, V_Hartree )
    !CALL Poisson_solve_ISF( Rhoe, V_Hartree )  ! for Lagrange-sinc functions
  ENDIF

  CALL excVWN( Npoints, Rhoe, epsxc )
  CALL excpVWN( Npoints, Rhoe, depsxc )

  V_xc(:) = epsxc(:) + Rhoe(:)*depsxc(:)

!  WRITE(*,*) 'sum(epsxc) = ', sum(epsxc)
!  WRITE(*,*) 'sum(V_xc) = ', sum(V_xc)
!  WRITE(*,*) 'sum(V_Hartree) = ', sum(V_Hartree)

  DEALLOCATE( epsxc )
  DEALLOCATE( depsxc )

END SUBROUTINE 

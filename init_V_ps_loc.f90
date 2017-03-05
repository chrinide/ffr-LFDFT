SUBROUTINE init_V_ps_loc_harmonic( omega, center )
  USE m_LF3d, ONLY : Npoints => LF3d_Npoints, &
                     lingrid => LF3d_lingrid
  USE m_hamiltonian, ONLY : V_ps_loc
  IMPLICIT NONE 
  INTEGER :: ip
  REAL(8) :: omega
  REAL(8) :: center(3)
  REAL(8) :: dx, dy, dz

  WRITE(*,*)
  WRITE(*,*) 'Initializing harmonic potential'
  WRITE(*,*) 'omega = ', omega
  WRITE(*,*) 'center = ', center

  DO ip = 1, Npoints
    dx = lingrid(1,ip) - center(1)
    dy = lingrid(2,ip) - center(2)
    dz = lingrid(3,ip) - center(3)
    V_ps_loc(ip) = 0.5d0 * omega**2 * ( dx**2 + dy**2 + dz**2 )
  ENDDO 

END SUBROUTINE 


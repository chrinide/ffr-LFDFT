!!
!! PURPOSE:
!!
!!   This subroutine calculates electronic density, given `psi`
!!   (which need not to be Kohn-Sham states) and occupation number `Focc`
!! 
!! AUTHOR:
!!
!!   Fadjar Fathurrahman
!!
!! MODIFY:
!!
!!   Global variable `rhoe`
!!
SUBROUTINE calc_rhoe( psi, Focc )

  USE m_LF3d, ONLY : Npoints => LF3d_Npoints
  USE m_states, ONLY : Nstates
  USE m_hamiltonian, ONLY : Rhoe
  IMPLICIT NONE
  REAL(8) :: psi(Npoints,Nstates)
  REAL(8) :: Focc(Nstates)
  INTEGER :: ist

  Rhoe(:) = 0.d0
  DO ist = 1, Nstates
    Rhoe(:) = Rhoe(:) + Focc(ist) * psi(:,ist) * psi(:,ist)
  ENDDO

  !WRITE(*,*)
  !WRITE(*,*) 'Calculating electron density'
  !WRITE(*,'(1x,A,F18.10)') 'Integrated electron density:', sum( Rhoe(:) )*dVol

END SUBROUTINE 


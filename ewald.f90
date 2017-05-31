!
! Copyright (C) 2001 PWSCF group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
! modified by Fadjar Fathurrahman for ffr-LFDFT (2017)
!
!-----------------------------------------------------------------------
FUNCTION ewald( alat, nat, ntyp, ityp, zv, at, bg, tau, omega, g, &
     gg, ngm, gcutm, gstart, gamma_only, strf )
  !-----------------------------------------------------------------------
  !
  ! Calculates Ewald energy with both G- and R-space terms.
  ! Determines optimal alpha. Should hopefully work for any structure.
  !
  !
  USE m_constants, ONLY : tpi => TWOPI
  IMPLICIT NONE
  INTEGER, PARAMETER :: DP=8
  !
  !   first the dummy variables
  !

  integer :: nat, ntyp, ityp(nat), ngm, gstart
  ! input: number of atoms in the unit cell
  ! input: number of different types of atoms
  ! input: the type of each atom
  ! input: number of plane waves for G sum
  ! input: first non-zero G vector

  LOGICAL :: gamma_only

  REAL(DP) :: tau(3, nat), g(3, ngm), gg(ngm), zv(ntyp), &
       at(3, 3), bg(3, 3), omega, alat, gcutm
  ! input: the positions of the atoms in the cell
  ! input: the coordinates of G vectors
  ! input: the square moduli of G vectors
  ! input: the charge of each type of atoms
  ! input: the direct lattice vectors
  ! input: the reciprocal lattice vectors
  ! input: the volume of the unit cell
  ! input: lattice parameter
  ! input: cut-off of g vectors
  COMPLEX(DP) :: strf(ngm, ntyp)
  ! input: structure factor
  REAL(DP) :: ewald
  ! output: the ewald energy
  !
  !    here the local variables
  !
  INTEGER, PARAMETER :: mxr = 50
  ! the maximum number of R vectors included in r
  INTEGER :: ng, nr, na, nb, nt, nrm
  ! counter over reciprocal G vectors
  ! counter over direct vectors
  ! counter on atoms
  ! counter on atoms
  ! counter on atomic types
  ! number of R vectors included in r sum

  REAL(DP) :: charge, tpiba2, ewaldg, ewaldr, dtau (3), alpha, &
       r (3, mxr), r2 (mxr), rmax, rr, upperbound, fact
  ! total ionic charge in the cell
  ! length in reciprocal space
  ! ewald energy computed in reciprocal space
  ! ewald energy computed in real space
  ! the difference tau_s - tau_s'
  ! alpha term in ewald sum
  ! input of the rgen routine ( not used here )
  ! the square modulus of R_j-tau_s-tau_s'
  ! the maximum radius to consider real space sum
  ! buffer variable
  ! used to optimize alpha
  COMPLEX(DP) :: rhon
!  REAL(DP), EXTERNAL :: qe_erfc

  !tpiba2 = (tpi / alat) **2

  charge = 0.d0
  DO na = 1, nat
     charge = charge + zv( ityp(na) )
  ENDDO
  alpha = 2.9d0
100 alpha = alpha - 0.1d0
  !
  ! choose alpha in order to have convergence in the sum over G
  ! upperbound is a safe upper bound for the error in the sum over G
  !
  IF( alpha <= 0.d0) THEN 
    CALL errore ('ewald', 'optimal alpha not found', 1)
    WRITE(*,*) 'ERROR in calculating Ewald energy:'
    WRITE(*,*) 'optimal alpha not found'
    STOP 
  ENDIF 
  !
  upperbound = 2.d0 * charge**2 * sqrt(2.d0 * alpha / tpi) * erfc ( &
       sqrt( gcutm / 4.d0 / alpha ) )  ! beware of unit of gcutm
  IF(upperbound > 1.0d-7) GOTO 100
  !
  ! G-space sum here.
  ! Determine if this processor contains G=0 and set the constant term
  !
  IF(gstart==2) THEN 
    ewaldg = - charge**2 / alpha / 4.0d0
  ELSE 
    ewaldg = 0.0d0
  ENDIF 

  ! gamma_only should be .FALSE. for our case
  IF(gamma_only) THEN 
    fact = 2.d0
  ELSE
    fact = 1.d0
  ENDIF 

  DO ng = gstart, ngm
    rhon = (0.d0, 0.d0)
    DO nt = 1, ntyp
      rhon = rhon + zv(nt)*CONJG(strf(ng, nt))
    ENDDO
    ewaldg = ewaldg + fact*abs(rhon) **2 * exp( -gg(ng)/alpha/4.d0 )/ gg(ng)
  ENDDO
  ewaldg = 2.d0 * tpi / omega * ewaldg
  !
  !  Here add the other constant term
  !
  IF (gstart==2) THEN 
    DO na = 1, nat
      ewaldg = ewaldg - zv(ityp(na))**2 * sqrt(8.d0/tpi*alpha)
    ENDDO
  ENDIF 
  !
  ! R-space sum here (only for the processor that contains G=0)
  !
  ewaldr = 0.d0
  IF( gstart==2 ) THEN 
    rmax = 4.d0 / sqrt(alpha) / alat
    !
    ! with this choice terms up to ZiZj*erfc(4) are counted (erfc(4)=2x10^-8
    !
    DO na = 1, nat
      DO nb = 1, nat
        dtau(:) = tau(:,na) - tau(:,nb)
        !
        ! generates nearest-neighbors shells
        !
        CALL rgen( dtau, rmax, mxr, at, bg, r, r2, nrm )
        !
        ! and sum to the real space part
        !
        DO nr = 1, nrm
          rr = sqrt (r2 (nr) ) * alat
          ewaldr = ewaldr + zv (ityp (na) ) * zv (ityp (nb) ) * erfc( sqrt (alpha) * rr) / rr
        ENDDO 
      ENDDO 
    ENDDO 
  ENDIF 
  
  ewald = 0.5d0 * e2 * (ewaldg + ewaldr)

  RETURN 
END FUNCTION 


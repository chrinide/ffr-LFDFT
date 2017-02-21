PROGRAM test_sch
  USE m_constants, ONLY: PI
  USE m_LF3d, ONLY : Npoints => LF3d_Npoints, &
                     dVol => LF3d_dVol
  USE m_states, ONLY : Nstates, &
                       evals => KS_evals, &
                       evecs => KS_evecs
  USE m_hamiltonian, ONLY : V_ps_loc
  IMPLICIT NONE
  !
  INTEGER, ALLOCATABLE :: btype(:)
  INTEGER :: dav_iter, notcnv
  REAL(8) :: ethr
  INTEGER :: ist, ip
  INTEGER :: NN(3)
  REAL(8) :: AA(3), BB(3)
  REAL(8) :: Ekin, Epot, Etot
  !
  REAL(8) :: ddot
  
  NN = (/ 25, 25, 25 /)
  AA = (/ 0.d0, 0.d0, 0.d0 /)
  BB = (/ 6.d0, 6.d0, 6.d0 /)

  CALL init_LF3d_p( NN, AA, BB )

  CALL info_LF3d()

  ! Set up potential
  ALLOCATE( V_ps_loc(Npoints) )
  CALL init_pot_harmonic( 2.d0, 0.5*(BB-AA) )
  WRITE(*,*) 'sum(V_ps_loc) = ', sum(V_ps_loc)

  Nstates = 4

  CALL sch_solve_Emin_cg( 3.d-5, 100, .FALSE. )
  GOTO 111


  ALLOCATE( evecs(Npoints,Nstates), evals(Nstates) )

  ALLOCATE( btype(Nstates) )
  btype(:) = 1 ! all bands are occupied
  DO ist = 1, Nstates
    DO ip = 1, Npoints
      CALL random_number( evecs(ip,ist) )
    ENDDO
  ENDDO
  CALL ortho_gram_schmidt( evecs, Npoints, Npoints, Nstates )
  DO ist = 1, Nstates
    WRITE(*,*) ist, ddot( Npoints, evecs(:,ist), 1, evecs(:,ist), 1 )
  ENDDO 
  evecs(:,:) = evecs(:,:)/sqrt(dVol)

  ethr = 1.d-1
  CALL diag_davidson_qe( Npoints, Nstates, 4*Nstates, evecs, ethr, &
                         evals, btype, notcnv, dav_iter )
  WRITE(*,*) 'dav_iter = ', dav_iter
 
  ethr = 1.d-3
  CALL diag_davidson_qe( Npoints, Nstates, 4*Nstates, evecs, ethr, &
                         evals, btype, notcnv, dav_iter )
  WRITE(*,*) 'dav_iter = ', dav_iter
  
  ethr = 1.d-6
  CALL diag_davidson_qe( Npoints, Nstates, 4*Nstates, evecs, ethr, &
                         evals, btype, notcnv, dav_iter )
  WRITE(*,*) 'dav_iter = ', dav_iter
  
  DO ist = 1, Nstates
    WRITE(*,'(1x,I4,F18.10)') ist, evals(ist)
  ENDDO

  DO ist = 1, Nstates
    WRITE(*,*) ist, ddot( Npoints, evecs(:,ist), 1, evecs(:,ist), 1 )
  ENDDO 

  evecs(:,:) = evecs(:,:)/sqrt(dVol)

  CALL calc_Energies( evecs, Ekin, Epot, Etot )
  WRITE(*,*) 'Ekin = ', Ekin
  WRITE(*,*) 'Epot = ', Epot
  WRITE(*,*) 'Etot = ', Etot

  DEALLOCATE( evecs, evals )
  
  111 WRITE(*,*) 'Deallocating ...'
  DEALLOCATE( V_ps_loc )
  CALL dealloc_LF3d()

END PROGRAM


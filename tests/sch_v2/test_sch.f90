PROGRAM test_sch

  USE m_constants, ONLY: PI
  USE m_LF3d, ONLY : Npoints => LF3d_Npoints, &
                     dVol => LF3d_dVol
  USE m_states, ONLY : Nstates, &
                       Focc, &
                       evals => KS_evals, &
                       evecs => KS_evecs
  USE m_hamiltonian, ONLY : V_ps_loc
  USE m_PsPot, ONLY : NbetaNL
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

  !CALL init_LF3d_p( NN, AA, BB )
  CALL init_LF3d_c( NN, AA, BB )

  CALL info_LF3d()

  ! Set up potential
  CALL alloc_hamiltonian()

  CALL init_nabla2_sparse()
  CALL init_ilu0_prec()

  CALL init_V_ps_loc_harmonic( 2.d0, 0.5*(BB-AA) )
  WRITE(*,*) 'sum(V_ps_loc) = ', sum(V_ps_loc)

  Nstates = 4
  ALLOCATE( Focc(Nstates) )
  Focc(:) = 1.d0

  NbetaNL = 0

  ALLOCATE( evecs(Npoints,Nstates), evals(Nstates) )

  DO ist = 1, Nstates
    DO ip = 1, Npoints
      CALL random_number( evecs(ip,ist) )
    ENDDO
  ENDDO
  CALL ortho_gram_schmidt( evecs, Npoints, Npoints, Nstates )
  DO ist = 1, Nstates
    WRITE(*,*) ist, ddot( Npoints, evecs(:,ist), 1, evecs(:,ist), 1 )
  ENDDO 
  
  DO ist = 1, Nstates
    WRITE(*,'(1x,I4,F18.10)') ist, evals(ist)
  ENDDO

  DO ist = 1, Nstates
    WRITE(*,*) ist, ddot( Npoints, evecs(:,ist), 1, evecs(:,ist), 1 )
  ENDDO 

  evecs(:,:) = evecs(:,:)/sqrt(dVol)

  !CALL Sch_solve_diag()
  CALL Sch_solve_Emin_pcg( 3.d-5, .FALSE. )

  !CALL calc_Energies( evecs, Ekin, Epot, Etot )
  !WRITE(*,*) 'Ekin = ', Ekin
  !WRITE(*,*) 'Epot = ', Epot
  !WRITE(*,*) 'Etot = ', Etot

  DEALLOCATE( evecs, evals )
  
  111 WRITE(*,*) 'Deallocating ...'
  
  DEALLOCATE( Focc )
  CALL dealloc_nabla2_sparse()
  CALL dealloc_ilu0_prec()
  CALL dealloc_hamiltonian()
  CALL dealloc_LF3d()

END PROGRAM


MODULE m_options

  IMPLICIT NONE 

  ! Options for controlling how beta is calculated
  INTEGER :: CG_BETA = 2
  ! 1 => Fletcher-Reeves
  ! 2 => Polak-Ribiere
  ! 3 => Hestenes-Stiefel
  ! 4 => Dai-Yuan

  ! whether free nabla2 after constructing matrix or not
  LOGICAL :: FREE_NABLA2 = .FALSE.

END MODULE 
